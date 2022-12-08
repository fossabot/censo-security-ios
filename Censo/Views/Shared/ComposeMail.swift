//
//  ComposeMail.swift
//  Censo
//
//  Created by Donald Ness on 2/18/21.
//

import SwiftUI
import UIKit
import MessageUI

/**
 # Attribution
 [SwiftUI: Send email](https://stackoverflow.com/questions/56784722/swiftui-send-email/58693164#58693164)
 */

struct ComposeMail: View {
    var subject: String?
    var toRecipients: [String]?
    var completion: ((Result<MFMailComposeResult, Error>) -> Void)?

    var body: some View {
        if MFMailComposeViewController.canSendMail() {
            _ComposeMail(subject: subject, toRecipients: toRecipients, completion: completion)
        } else {
            Text("Cannot send mail from this device")
        }
    }
}

fileprivate struct _ComposeMail: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    
    let subject: String?
    let toRecipients: [String]?
    let completion: ((Result<MFMailComposeResult, Error>) -> Void)?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
        
        @Binding private var presentation: PresentationMode
        private var completionHandler: ((Result<MFMailComposeResult, Error>) -> Void)?
        
        init(
            presentation: Binding<PresentationMode>,
            completionHandler: ((Result<MFMailComposeResult, Error>) -> Void)?
        ) {
            _presentation = presentation
            self.completionHandler = completionHandler
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            
            if let error = error {
                completionHandler?(.failure(error))
            } else {
                completionHandler?(.success(result))
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, completionHandler: completion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<_ComposeMail>) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        
        controller.mailComposeDelegate = context.coordinator
        
        if let subject = subject {
            controller.setSubject(subject)
        }
        
        if let toRecipients = toRecipients {
            controller.setToRecipients(toRecipients)
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<_ComposeMail>) {
        // Nothing to update
    }
}
