//
//  ContentView.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 05/05/21.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var errorText: String = "Invalid credentials please try again...!"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")

    var validUserName: String = "natwar@gmail.com"
    var validPassword: String = "Natwar"

    @State var isUserAuthenticatedSuccessfully: Bool = true
    @State var isMapViewPresented: Bool = false

    @State var userName: String = ""
    @State var password: String = ""
    
    var body: some View {
        NavigationView {
            ZStack() {
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomLeading)
                    .ignoresSafeArea()

                VStack {
                    VStack(alignment: .leading) {
                        UserNameField(userName: $userName)
                        if(!emailPredicate.evaluate(with: userName) && !userName.isEmpty){
                            Text("Inavlid email format!")
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                        }
                        PasswordField(password: $password)
                        if (!isUserAuthenticatedSuccessfully) {
                            errorView(errorText: self.errorText)
                        }
                    }

                    if (emailPredicate.evaluate(with: userName)) {
                        NavigationLink(destination: SearchLocationsScreen()
                                        .navigationBarHidden(true),
                                       isActive: $isMapViewPresented,
                                       label: {
                                        VStack() {
                                            Button(action: {
                                                if (userName == validUserName && password == validPassword) {
                                                    self.isUserAuthenticatedSuccessfully = true
                                                    UserDefaults.standard.set(true, forKey: "isUserLoggedin")
                                                    isMapViewPresented = true
                                                } else {
                                                    self.isUserAuthenticatedSuccessfully = false
                                                    isMapViewPresented = false
                                                }
                                            }, label: {
                                                LoginButtonView()
                                            })
                                        }
                                       })
                    }
                }
            }
        }
    }

    struct UserNameField: View {
        @Binding var userName: String
        var body: some View {
            TextField("User Name", text: $userName)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
        }
    }

    struct PasswordField: View {
        @Binding var password: String
        var body: some View {
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .padding(.trailing, 10)
                .padding(.leading, 10)
                .padding(.bottom, 10)
        }
    }

    struct LoginButtonView: View {
        var body: some View {
            Text("Login")
                .padding()
                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 15)
                .font(.title)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(UIScreen.main.bounds.width / 6)
                .padding(.top, 10)
        }
    }

    struct errorView: View {
        var errorText: String
        var body: some View {
            Text(errorText)
                .padding()
                .foregroundColor(.white)
                .background(Color.clear)
                .padding(.top, 10)
                .padding(. bottom, 10)
        }
    }

}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
