//
//  AddDeviceRow.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI


struct AddDeviceRow: View {
    var requestType: ApprovalRequestType
    var addDevice: AddDevice

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            Text(addDevice.email)
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}


#if DEBUG
struct AddDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        AddDeviceRow(requestType: .addDevice(.sample), addDevice: .sample)
            .preferredColorScheme(.light)
    }
}

extension AddDevice {
    static var sample: Self {
        AddDevice(
            name: "User Name",
            email: "user@a.com",
            jpegThumbnail: "/9j/4AAQSkZJRgABAgAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAEAAQADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5/ooooAKKKKACiiigAooooAKKKKACiirFpYXl/J5dnaz3L/3YYy5/SgCvRXpeg/A/xXrS75FhsEwD/pccqHnHbZXZ2X7NTcm+8TKPaC1z+pb+lAHgNGD6V9L2/wCzl4cjOZtX1OU+wjA/VTWpH8BPCEY5k1Bv94xf/G6APlTB9KK+q5fgJ4QkHEmoL/umL/43WXcfs5eHJDmHV9UiPuIyP0UUAfNFFe/Xv7NTcGx8TKfae1x+ob+lcZr3wP8AFeirvjWG/TBP+iRyueM9tlAHmlFWLuwvLCTy7y1ntn/uzRlD+tV6ACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKK1NC8Pan4k1FbLTLWWeUldxSNmEYJAy20HA560AZddl4O+Gmv+M5W+xw/ZrdNubi5jkCHOOhCkE4OfpXufgf4G6V4amN5q9xHqt2dpWNoFMUZGCcBgSTkdeOO1ergBVCgAADAA6CgDyPwz8AdD0eQT6nfS6nNhfkaBBEMYJ4YNnn3HFeq2ljaWEXlWdrBbR8fLDGEH5CrFFABRRRQAUUUUAFFFFABRRRQBXu7G0v4vKvLWC5j5+WaMOP1ryrxN8AdC1iQz6ZfS6ZNhvkWFDEc5I4ULjn3PFeu0UAfGnjH4aa/4MlX7ZD9pt33YuLaOQoMZ6kqADgZ+lcbX34QGUqQCCMEHoa8o8cfA7SvEswvNInj0q7G4siwKIpCckZCgEHJ688dqAPlqitTXfD2p+G9Ray1O1lglBbaXjZRIASMruAyOOtZdABRRRQAUUUUAFFFFABRRRQAUUUUAFFFem/Cv4VyeN5Z76+nktNNtXQcRZaduCVUkbcbe/PUcUAZ3w5+GF/4+uZ3Fx9isLcr5k7xMd5JGVTsTjnr6etfVfh7w3pnhjTVsdLto4owF3ssaq0hAA3MVAyeOtaNvbw2lvHBbxJFFGoVERQoUAYAAHtUtABRRRQAUUUUAFFZz63YLMY1uI5Cv3yjqQn+9zx3/ACNCzrrFuxtLlo4wSpdep46gg+9LmXQ19jJayVkX3kSMAu6rk4G44zTqyxb6dodu9zK6jA+aaYruOBn73HpmuVn+K2kxq/l2dzIykhRuQA/jk1EqkY/E7G9LBVsRf2EXJI76ivJ2+L90T8mkQj6zE/0qzYfEfXtUk8q10KOQsQoZBIQpPc4B4qFiab2Z1yyLGxXNKKS9V/men0Vy4ufF0saEW2mRllBIYy5H6Vr6curjJ1CSzIwMCBX/AJk/0rVSv0OCph3BXcl95o0UUVRzhRRRQBk+IfDemeJ9Max1O2jmjIbYzRqzRkgjcpYHB5r5U+Ivwxv/AADcwsbj7bYXBby50iYbME4V+wOOevr6V9g1Fc20N3byW9xEksUilXR1DAgjBBB9qAPgeivTPin8LJPBE0N7YzyXenXTuBmLBgPJCsQMY29+Oh4rzOgAooooAKKKKACiiigAoorU8P6HeeItattMskJlmkVCwQsIwWC7jgdBuFAHUfDD4dT+PtVnDTm2sLPY08nlkl8t9xT0zjJ59uDX15bW8NpbR29vGkcUShERFACgDAAA9qzfDfh2y8L6JBpdigEcSKGfYqmRgoUscDknaK16ACiiigAoorjPFvj230FBBZCK6uySCN4KpjI5wc5yBxUzmoK7N8PhquJmqdJXZ0Osa7Y6HaNPdzICASse9QzYBOACR6V5nNqev/ES6FvZxmxs4vvMpk2kE4+YjgnB6fWqWgaImsG51zxDdtFbIdyhzgyn75AL8EYz+daWpfFJBaG10fTvIQoV3yHBHGBgKeK5JVeZXk7Lt3PpMPgHh5OGHjz1FvJ6KP8AmbVto+i+A7Iy6nd/bZHYFI3CcEDqqsfbrn0rB1T4sXsx2adYxQx8jdKxZj/3yRj9a4SOO91S5Cos9zMx7BnPJ/Hua9K0H4VqoE+r3W4kArFCvToedw/DpURnUn7tNWR118Ng8L+9x0ueb/rRI4eafWvFl8u4TztnAA3sq5P44611OkfCi7uPn1K9WBOMJEhLH/voDFehXeoaP4TsI428qFCMLGmxWfA644z0qO5fU9f0y3fTXFgkq7nadW8wAqMYCkep79RWioRT97VnDVznESilQiqcNr/0iDS/A2h6OpYQic8EtcojYx/wEVePiXQYJhANUsFPtcRgDtjrWPaeALRGMl7ql9fsf+ezhl/Ig/zrZ0zS7K3aQR6Ta24U4VxGNzf+Oj2raKa0SseVXnSm3KpUc3935/5Glb3Nvdx+ZbTxTJnG6Nww/MVC1xcmQrHaggHGXcqD/wCOmp5YjJHtVzHz1Wsm58MWd3f/AG2Sa4E3baw45J449TWjv0OOmqTb5nZff/kbIzgZ4PtS1VmsUntPszSyhcY3K3zdMdanijEUSxgsQoAyx5NMyaVtGPooopkhRRRQBDdWsN7bSW9xGkkUilHR1BBBGDwfY18hfEz4dz+AtWhUTm5sbve0Emwjbhj8hOMZxg8e/FfYdY3ijw3ZeKdEn029UbJFYI+wMY2KlQwyOCM0AfDdFaWu6Ld+H9YuNOvEIlhkZAxUqHAYruGexwazaACiiigAooooAK+pPgZ4Il8OaHPrF5/x9amkZjUxkGOLaGAyRnJLc9vlFeF/DfwfJ4z8Vw2QbbBBtnnbYWzGHUEemSCevHFfZgAVQqgBQMAAYwKAFooooAKK5zWtXmfVrbRdP/10o8yaUMf3ce7YcY53ZOeeOKm8U+JrfwxpyTzRvK8pKRKpAywGecnp06etQ5pXb6HTHCVZOEYq7lsjD+IPi7+xrZdPtcm5uEbLq+PLXBXPBznP8q8XJLEkkknqTUt3dS3t3LczMWklcu2STyTnv9ahry6tV1JXP0PLsBDBUeRb9X3JZbmecKJppJAowodicD2zTE2bxvLBc87Rk02lBKkEHBHINZnfZJWR67pKqdLivLkxaHYRYKxRny5bnCg5YnaDkcdDzmrNvr2s+MZJodIhXT7KM4a5n37mzx8u3jODnrXk0OoM+oQ3OoNLdrG4Yo8mdwBzjJzwa76H4r3ch8m30KMsRtRUlJweg4C89uK7IVovRu36ny+LyytF81OCm+jbSUfvevzO60fwrYaRGxObu4bBM9yqs+fY4z15qwmiq14bm5uppz/DEx/drznhTn6fSszQbHXZ5FvtWvvLBAK20O8AZwfm3H8MYrp664JNbWPmMRUqRqO8+Z9X/X6CAADAGB7UtFFaHGFFFFABRRRQAUUUUAFFFFABRRRQB5B8dPBMmvaPb6zZ/wDHzp6SGRRHkvHtLdQM5yvHbk18w199yRrLGyOAVYEEEZ4r4v8AiF4Tk8IeKJrJm3Qyl5oTsKjZvYAfgAOnrQBylFFFABRRU9lave31vaR/fnlWJeM8scD+dAH0t+z94afSfDN9qs4Hm6hJHs+TBEYQMOSO+8+3FewVW0+yj07TbWxix5dvCkS4GOFAH9Ks0AFZ2u6mNI0e5vNu5o42KrnGSFJH8q0a80+LWptFb2GnxOQZC8kmGxxjaBj8T+VZ1Z8kGzty7DfWcTCl0f6alT4V3EJ1HUZ7m4Bu58BVZhkjOSeTnqwrI+I/iFdY1eO1h/1FpvXIbO5txBPHHQCszw1dLplnqeoFlEnk+RECcHcwLAj6bO3rXOnk5rzpVH7JQPt6WBi8fPEvpZL7v8gooorA9gKKKltbeS7uoreIZklcIox3JwKYm0ldlnSdJudZv0tLVcuxGTgkKCQMnA96958O+GLLw5aGK3G+Vsb5WVQxOB6Dpxmo/Cvhe38Mae0Mb+bNKQ0kpUA5wBge2QT+Nb9elQociu9z4HOM3eLl7Om/cX4hRRRXSeEFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFeNftBeG21LQbDVYQPMsnkD/LnKFSx5A/2fpzXstUdY0+PVNIurKTG2aF0ORnqpH9aAPhCipry3e0vJ7aT78MjRtxjkHFQ0AFej/BTQRrfj2JmxsskW65XPKyx8fzrzive/2arPNz4hvj/CkMI49SxP8AIUAfQVFFFADJpUggkmkOERSzH2AzXzlrmsTa5qkt7MNpYnauSdqliQOfrXuHjS4Fv4WvTuClopFGTjJKNXz7XDjJaqJ9hwxQjyzrPfYeJXERiDHYWDEZ4z/k0yiiuI+rsFFFFIYV6J8LdBW8vLnVJidtuVSMberZDZ59MD8688UFmCjqTivoXwnoQ8P6HHal9zuRJIcY+YqoP8q6cNDmnfseFn+L9hheRPWX5dTcooor0z4AKKKKACiiigAooooAKKKKACiiigAooooAKKKKACg0UUAfIXxh0P8AsXxzOFHy3Qe4Hy45Mr//AFq8/r3X9pCx8vUdCvB/HHLGePcH+prwqgAr6T/Zvh2+FNYnPWS+C9PRAf8A2avmwdRX1L+z9GE8AXLf3r4/+io6APWKKKKAOC+K8uzw7apn71x6/wCw3+NeNV618Xs/2bpnp5z/AMq8lrzMU/3jP0Hh+NsDF92/zCiiiuY9sKKKKANrwrpiatr9tbSbtm9WbaM8blB/nX0RXjnwniV9fu2ZAStuMEjp8wr2OvSwkbQufCcSVnLFKn0ivzCiiiuo+eCiiigAooooAKKKKACiiigAooooAKKKia5jW7S2LfvXQuBnqAQD/MUDSb2JaKrXt4LJImZSweQR8HpnP+FWaLg4tJMKKKKBHiP7SMO7w9o046pdMv5oT/SvnCvqD9oSMP4Jsm/u3h/9FvXy+epoAB1FfUn7PsgfwDcqP4b8/wDoqOvluvpP9m+bd4V1iDvHfK/X1QD/ANloA9qooooA86+LuP7G0/JOftBx/wB815FXt/xK0qbU/D8LW8bySQSlyqKW+XY2Tx9BXiFeZil+8uff8PTi8Eop6pv8wooormPdCiiigD0T4S3UEGq38MjBZJYk2ZI5w2CP1FevV816Nci01iznZtqxzIxPoAwNfSYIZQQcgjIIr0sJK8Ldj4XiTD8mJVX+ZflZC0UUV1HzoUUUUAFFFFABRRRQAUUUUAFFFFABWHKGPja3wMqunvk+hMif4fpU3iHXrfw7phvJ1L5JVEDAbm2kgc/SvNdI8aSs2oXB/wCP/UbgRQoGJ8pTuI75xlx09KxqVYxaiz1cDgK1anKrFabff/luenazYvfwW6RnBjnWT8gf8a0qKRWV1DKwIIyCD1Fa21uea5txUeiFooopkHkP7QkgTwVZL/evD/6LevmA9TX0d+0jNjQNFg7tdM/X0Uj+tfONABXvX7Nd4Rd+IbE/xxwzDn0LA8fiK8Fr0T4Ma8ND8ewBvuXqpaH5sY3Sx8/zoA+uaKBRQAyVVeF1f7pUg/Svma7t2tLua3Y5aJ2Qn1wcV9OV86eJdKm0jXLi3mycuzIxBGV3EA8/SuLGLRM+q4XqJTqQb3t+pkUUUVwH2QUUUUAFe++B9cXW/D8bYIktwsL5OckIOf514FXS+C/E6+GdUkllSSSCZQjqjYx8w5x0PGfzrfD1OSeux5Gc4F4vD2gveWqPfaKZFKk0KSxsGR1DKQc5Bp9eqfnTVgooooAKKKKACiiigArmvEHjXT/D0/kTI0spjLhUZeuSAOT7Gl8VeMbTwxCgZDPcyg7I1YcY7nnOM15T4csk13VrvUtTm/cWw+0S5OS3zbio3cdA3WuerWs+WO57mW5YqkHiMQnyLbzPdoJDLbxyFdpdQxX0yOlSVyuv+ObLQdPtJ2t5ZZbuLzIogVBUYyN3PHXHGe9eZeIPH2q68kSD/QkjJJFvIy7s+vPNOpiIQ06mWDybE4p8yXLHuzY+KWux315babDgpblndg2fmyVxx6Y/WuZ8IWDah4ls0UE+XKkjYGcAOv8AjWGSSSSSSepNehfCvSxNqNzqEk2xYwI0ToXbIbP4YH/fVcMW6tW7PrasIZfl7hF7L8WepyWJl+1Bp3H2iPy+P4R83I9/m/SotNRjLcykjZuEcajoFXOD/wCPfpWjTY41ijCIAFAwABXqW1Pz/wBo+VpjqKKDTMz51/aQvvM1TRLMdI4pZDz/ALQH9DXhld38Wtc/tvxxcsp+W23wD5s9JHrhKACprS4e0vIbmP78MiyLzjkHIqGigD7y0u/j1TSrS/ixsuYUlABzjcoOP1q3XjX7PniR9S8P6hpE5HmWMiPGS2cxlAoGCe2z6c17LQAVwvxO0M6lpEN7EP3tpvLYXOU2kn/0H9a7qmyIssbRuMqwKkexqJwU4uLOnCYmWGrRqx6Hy/RW14n8PzeHdWa1lbej5eNwpGV3ED8eP1rFryGnF2Z+n0qsasFODumFFFFSaBRRRQB0/h3xxqegvtLNdW/A8qWVsKBj7vOBxx0r17QfFena9ZG4jb7Ph9hSZ1BLYB4556189UV0U8RKGm6PGx+S4fF+8vdl3X+R9RUV87aX4q1fSOLe7lKcfI8j7ePYEV0KfFTWlXDW1qx9fn/+Krqji4Pc+eq8N4qL9xpr7j2iivHF+LGrgc2Vofxf/Gkn+K+rSxbY7K2jbBBbc5/rVfWqZj/q9jr7L70ewyzRQRl5ZEjQdWdgBXAeJ/iVbWUZt9KRbiZtwaQuNq9RkbTnOfpXlV/qd5qUvmXdzLMckje5bH0yaqVz1MW3pHQ9rB8N0qbUq8uby2RLPcTXUzSzyvJIxyWdiT69TTFYowINNorkPpUklZFzU9UutWuvtF3IXkA2jLE4GScDJPHNU6KKG76sUYqC5YqyJba3kuriOCJSXdgowM9TivYvBNhJZym4kh2hoxBbqFI3RjBMh46nK9OOOvSuA8DaVPq2rzQREonlYlkCk7VLAHHv9fSvdooo4UREUAIoUcdAK7MLTv7x8rxDjuV/V18ySiiiu8+PCs3XtTj0jRLu9kxtihduTjopP9K0q8T/AGhPEjWWkadpEBG+6Z3kIbogUqRgH/a/SgD50up2urqa4f78rtI3PcnNQ0UUAFFFFAHU+APFs3g7xRBqCAtDIVinXeV/d71Y/ovfjmvtGORZY1kRgysAQQcgg18C19MfAjxvJrOl3Oh3p/0ixSMwsXzvj2hMYJzwV7cfNQB7LRRRQByfjnwofEthHJFL5dxah2Qbc78j7vr1ArwuSN4pGjkUq6kgqwwQa+oK4fxz4H/t4Je2TpFcxI25NnEg5PYZzn+dcmIoc3vR3PpckzdULYes/d6Pt/w54rRT5IpIZDHKjI4OCrDBFMrzz7ZO4UUUUhhRRRQAUUUUAFFFFABRRRQAUUUUAFXtJ0m61m/jtbWNmZmAZgpIQEgZOO3NV7S3N3dRQeYke9wpdzhVycZJ9BXVav4jttOsV0fQA8can99dBgHlIG3gp1Hfn1q4xW8jlxFWomqdJXk/uXm/8j1OxtNN8G6MkXmJlsDJ2q0rhcYHTJOOnvWtaWqQeZIC5eZt7b+o9voMmuD8AeHbyXOr6zLPMwCrbR3GW2j5W3DcPp0969Fr1KWsb2sfnmPiqdVw5+Z9WFFFFanARXE6W1vJNIwVEUsSTjoM18WeOPFE3izxLPfyArGrPHEu8t8m9iP59q9t+PHjdtMsLbQrI/vrpZDMwfG1MFMYB9SevpXzbQAUUUUAFFFFABV7R9VutF1S31C0kZJYJFcAMVDYYNtOOxwKo0UAfbvg/wAV2Xi7RItQsyBlVEke9WKMVDFTg9Rmugr40+Hnj+68CatJOkP2i1uAqzxbyOAwO4ds4yOfWvr/AEzUrbVrGK7tZFkikVWBVg3BAI5H1oAuUUUUAcf448Gt4lhgltJIobqHdkuvDqecZAz1/ma8VvbK40+6e3uY2SRCQQykZwcd/pX01WPr/huw8RWoiu02uudsqqu5cgjqQfXP4Vy1sOp+9Hc+gyrO5YVKlV1h+K/zPnWiut174f6ro8x8kNdwYZg8UbEgD1wMA4965KvPlBxdmfa0MRSrx56UroKKKKk3CiiigAooooAKKKKACiiug8OeD9R8SSuIMQxRkbpJVbH4YHJqoxcnZGVatTowc6jskYABY4UEk9hXpHgbwFJNKNS1VTGiMpigePljw2TuHTtx713fh3wnp/hy2aOECaViC0siLuyB2wOnet6u6lhbayPkMx4hdWLpYdWXf/gdA6DAooorsPlwrm/Gni6z8H6HJfXWGYhhHHvClmCkgDJ9q1tW1W10ewkvLuRUijVmO5gvQE9/pXyB8QPHl1451dLmWIwW8G5YYt5PBYnJ5wDjA49KAOc1XU7nV9Snvrp2eWZ2c5YttyScDPbk1SoooAKKKKACiiigAooooAK7/wCGvxKuPA13NHJA11Y3DLvj8wgxkEZZRnHT+Q5rgKKAPvDS9VtNXskurSVJInUMCjhhyAeoPvV2vjLwH8QdQ8DX0slvGLi2n2+ZA0jKOCORg4zjjkV9U+EvGul+L9P+1WMihgF3xGRSyEgHBAJx1xQB0lFFFABXKa/4A0nXNrKPscqliWgiQbif73HP511dFTKKkrM2oYirQlz0pWZ4trPwx1PT23Wcy3kRyfljbcPwANcmdIv1laJrSdZF/haNgT9BivpWmsiuAGUNjnkZrmlhIt6Ox71DiXEQjapFS89j5mmsrq3GZ7aaIf7cZX+dRJG8jBURmJ6ADNfUBAIwRkUgVV6AD6Cp+p/3jpXFLtrS/H/gHy9U1va3F3II7eGSViQMIpb+VfS5toC24wxluudgzUtJYP8AvDlxTppS/H/gHznB4Z1m4kZE066ypwcwP/hXT6f8KtWusNc3dvbrx/Cxb8iBXstFaRwkFvqcdbiTEzVqaUfxOT0j4e6NpYRnX7VIuDumjQjIx2x7etdWAAMAYpaK6IxjFWSPDr4irXlzVZXYUUUVRiFUdV1a00axe7vJUjiQE5ZwucAnufasjxd420vwfp/2m+kVnYNsiEihmIBOACR6Yr5W8d+P9Q8c30UtynkW8O7y4FkZhyTycnGccdKAL3xI+JFz45vIVWFrayt2bZH5hO/JOGIzjp/XmuCoooAKKKKACiiigAooooAKKKKACiiigAq5puq3ukXiXVjcSwSqwOY3K7sHODgjI4qnRQB9IeCfjxbag4stctFtZflCzrMNjdAc7yMevevZ7e6hu4hJBIjqQCCrA9fpXwRXReGfGus+FrgyWFwxQ7cxSSPs4PoGHpigD7borw/w5+0LZ3TCDWNLe3bgCSOYFT0ByWIx6161pXiTSdZi8yyvbeQYBO2VWxn6E0Aa1FICCKWgAooooAKKKKACiijNABRWVqviPStGi8y9vreIYJAaVVPH1IryTxH+0LZWrGDR9Le4fkGWWYBR1AxtJz60Ae1XF1DaxNLPKkaAE5dgOn1rxfxt8eLbT2NloVot1L8wadphsXqBjYTn17V4l4m8a6z4quBJf3LhBuxEkj7Bk+hY+uK52gC5qWqXmrXj3V7cSzSsxOZHLbcnOBknA5qnRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABUsNxNbvvhleJv7yMVP6VFRQB2ui/FHxNooAjvHuF44uJZG6f8D9q7ix/aM1SHi60S3m6crOw/nmvEqKAPoqH9pGwP+v0C5X/clU/zxV6P9orw+4+bSdQX/gUf+NfM9GaAPpiT9orw+g+XSdQb/gUf/wAVVGb9pHTx/qPD903/AF0lUfyzXzrmigD26+/aM1Sbi10O3h68vOx/liuG1v4peJ9bBEl69uvPFvNIvX/gfvXFUUASzXE1w++aV5W/vSMWP61FRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH/2Q==",
            deviceGuid: "",
            deviceKey: "",
            deviceType: DeviceType.android
        )
    }
}

#endif
