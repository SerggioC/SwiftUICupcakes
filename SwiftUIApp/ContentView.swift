//
//  ContentView.swift
//  SwiftUIApp
//
//  Created by Sergio on 18/06/2019.
//  Copyright © 2019 Sergio. All rights reserved.
//

import Combine
import SwiftUI

class Order: BindableObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case type, quantity, extraFrosting, extraTopping, extraSpinkles,
        name, phoneNumber, address
    }
    
    var didChange = PassthroughSubject<Void, Never>()
    
    static let types = ["Vanila", "Chocolate", "Strawberry", "Rainbow"]
    
    var type = 0 { didSet { update() } }
    var quantity = 1 { didSet { update() } }
    
    var specialRequestEnabled = false { didSet { update() } }
    var extraFrosting = false { didSet { update() } }
    var extraTopping = false { didSet { update() } }
    var extraSpinkles = false { didSet { update() } }
    
    var name = "" { didSet { update() } }
    var phoneNumber = "" { didSet { update() } }
    var address = "" { didSet { update() } }

    var isValid: Bool {
        if name.isEmpty || phoneNumber.isEmpty || address.isEmpty {
            return false
        }
        return true
    }
    
    
    func update() {
        didChange.send(())
    }
}

struct ContentView : View {
    
    var title = "Apple Cupcakes"
    
    @ObjectBinding var order = Order()
    
    @State var confirmationMessage = ""
    @State var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                
                Section{
                    Picker(selection: $order.type, label: Text("Select your Cake Type")) {
                        ForEach(0..<Order.types.count) {
                            Text(Order.types[$0]).tag($0)
                        }
                    }
                    Stepper(value: $order.quantity, in: 1...10){
                        Text("Number of Cakes \(order.quantity)")
                    }
                }
                
                Section{
                    Toggle(isOn: $order.specialRequestEnabled) {
                        Text("Any Special Requests?")
                    }
                    if ($order.specialRequestEnabled.value){
                        
                        Toggle(isOn: $order.extraFrosting) {
                            Text("Extra Frosting")
                        }
                        Toggle(isOn: $order.extraTopping) {
                            Text("Extra Topping")
                        }
                        Toggle(isOn: $order.extraSpinkles) {
                            Text("Extra Sprinkles")
                        }
                        
                    }
                }
                
                Section {
                    TextField($order.name, placeholder: Text("Enter your name").color(Color.blue))
                    TextField($order.phoneNumber, placeholder: Text("Enter your phone number").color(Color.blue))
                    TextField($order.address, placeholder: Text("Enter your address").color(Color.blue))
                }.padding(4)
                
                Section{
                        Button(action: {
                            self.placeOrder()
                        }) {
                            Text("Place Order!")
                        }
                    }.disabled(!order.isValid)
                
                }
           
                .navigationBarTitle(Text(title))
                .presentation($showingConfirmation){
                    Alert(title: Text("Thank you!!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
            }
//        Spacer()
        }
        
    }
    
    func placeOrder() {
        guard let encodedData = try? JSONEncoder().encode(order) else {
            print("failed to encode this thing!")
            return
        }
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) { responseData, responseURL, error in
            
            guard let data = responseData else {
                print("No data in response")
                return
            }
            
            if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                self.confirmationMessage = "Order received from mister \(decodedOrder.name) for \(decodedOrder.quantity) Cupcakes! \n Cupcakes on the way!"
                self.showingConfirmation = true
            } else {
                let dataString = String(decoding: data, as: UTF8.self)
                print("Error decoding: \(dataString)")
            }
            
            
        }.resume()
        
        
    }

}




#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
