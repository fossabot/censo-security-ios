//
//  KeyConfirmationSuccess.swift
//  Strike
//
//  Created by Ata Namvari on 2022-07-12.
//

import SwiftUI
import BIP39

struct KeyConfirmationSuccess: View {
    @Environment(\.strikeApi) var strikeApi

    @RemoteResult private var signers: StrikeApi.Signers?

    var user: StrikeApi.User
    var phrase: [String]
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch $signers {
            case .idle:
                StrikeProgressView(text: "Registering your key with Strike...")
                    .onAppear(perform: reload)
            case .loading:
                StrikeProgressView(text: "Registering your key with Strike...")
            case .failure(let error):
                RetryView(error: error, action: reload)
            case .success:
                VStack {
                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.Strike.green)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding()
                        .frame(width: 100, height: 100)

                    Text("You're all set.")
                        .font(.system(size: 26).bold())
                        .padding()

                    Spacer()

                    Button {
                        onSuccess()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(30)

                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(StrikeBackground())
    }

    private func reload() {
        do {
            let rootSeed = try Mnemonic(phrase: phrase).seed
            let privateKeys = try PrivateKeys.fromRootSeed(rootSeed: rootSeed)

            _signers.reload(
                using: strikeApi.provider.loader(
                    for: .addWalletSigners(
                        StrikeApi.Signers(
                            signers: [
                                StrikeApi.WalletSigner(
                                    publicKey: privateKeys.solana.encodedPublicKey,
                                    walletType: WalletType.Solana,
                                    signature: nil
                                ),
                                StrikeApi.WalletSigner(
                                    publicKey: privateKeys.bitcoin!.getBase58ExtendedPublicKey(),
                                    walletType: WalletType.Bitcoin,
                                    signature: nil
                                )
                                ],
                            userImage: nil
                         )
                    )
                )
            ) { error in
                do {
                    try Keychain.saveRootSeed(rootSeed, email: user.loginName)
                    try Keychain.savePrivateKeys(privateKeys, email: user.loginName)
                } catch {
                    _signers.content = .failure(error)
                }
            }
        } catch {
            _signers.content = .failure(error)
        }
    }
}

#if DEBUG
struct KeyConfirmationSuccess_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeyConfirmationSuccess(user: .sample, phrase: [], onSuccess: {})
        }
    }
}
#endif
