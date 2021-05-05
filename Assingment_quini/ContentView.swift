//
//  ContentView.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 05/05/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var validUserName: String = "Natwar"
    var validPassword: String = "Natwar"
    
    @State var isUserAuthenticatedSuccessfully: Bool = true
    
    @State var userName: String = ""
    @State var password: String = ""
    
    var body: some View {
        ZStack() {
            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomLeading)
                .ignoresSafeArea()
            
            VStack() {
                UserNameField(userName: $userName)
                PasswordField(password: $password)
                if (!isUserAuthenticatedSuccessfully) {
                    Text("Invalid credentials please try again...!")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .padding(.top, 10)
                        .padding(. bottom, 10)
                }
                Button(action: {
                    if (userName == validUserName && password == validPassword) {
                        self.isUserAuthenticatedSuccessfully = true
                        userName = ""
                        password = ""
                    } else {
                        self.isUserAuthenticatedSuccessfully = false
                        userName = ""
                        password = ""
                    }
                }, label: {
                    LoginButtonView()
                })
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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
    }
}
