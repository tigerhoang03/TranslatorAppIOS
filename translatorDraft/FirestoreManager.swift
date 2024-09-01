//
//  FireStoreManager.swift
//  translatorDraft
//
//  Created by Aman Sahu on 8/9/24.
//

import FirebaseFirestore
import Combine


/**
 The `FirestoreManager` class provides an interface for interacting with Firestore.
 It includes methods to add, retrieve, and manage conversation data in a Firestore database.
 */
class FirestoreManager: ObservableObject {
    private var db = Firestore.firestore()
    
    
    /**
     Adds data to a specific conversation in Firestore.
     
     - Parameters:
        - data: A dictionary containing the data to be added.
        - conversationNumber: The number of the conversation to which the data will be added.
        - user: The user identifier for the document.
     */
    func addDataToConversation(data: [String: Any], conversationNumber: Int, user: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("conversations").document("\(conversationNumber)").collection("data").document("\(user)")

        docRef.setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document written successfully")
            }
        }
    }

    
    /**
     Retrieves data from a specific document in Firestore.
     
     - Parameters:
        - collection: The name of the collection.
        - document: The name of the document.
        - completion: Closure called with the document data or `nil` if the document does not exist.
     */
    func getData(collection: String, document: String, completion: @escaping ([String: Any]?) -> Void) {
        let docRef = db.collection(collection).document(document)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(document.data())
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    
    /**
     Retrieves the current conversation number from Firestore.
     
     - Parameter completion: Closure called with the current conversation number or `nil` if it cannot be retrieved.
     */
    func getCurrentConversation(completion: @escaping (Int?) -> Void) {
        let docRef = db.collection("conversations").document("current")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data(),
               let currentConversation = data["number"] as? Int {
                completion(currentConversation)
            } else {
                print("Document does not exist or has no number")
                completion(nil)
            }
        }
    }
    
    
    /**
     Creates a new conversation in Firestore, including initializing conversation metadata and adding sample data.
     
     - Parameter completion: Closure called with the new conversation number or `nil` if creation fails.
     */
    func createNewConversation(completion: @escaping (Int?) -> Void) {
        getCurrentConversation { currentConversation in
            guard let current = currentConversation else {
                print("Failed to get current conversation number")
                completion(nil)
                return
            }
            let newConversation = current + 1
            
            self.db.collection("conversations").document("current").setData(["number": newConversation]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    completion(nil)
                } else {
                    // Create a new document with the title as newConversation value and metadata inside it
                    let conversationDocRef = self.db.collection("conversations").document("\(newConversation)")
                    
                    let metadata: [String: Any] = [
                        "timestamp": Timestamp(),
                    ]
                    
                    // Set metadata for the new conversation document
                    conversationDocRef.setData(metadata) { err in
                        if let err = err {
                            print("Error creating new conversation document: \(err)")
                            completion(nil)
                        } else {
                            // Create a new subcollection "data" inside the conversation document
                            let dataCollectionRef = conversationDocRef.collection("data")
                            
                            // Add string documents inside the "data" subcollection
                            let dataEntries = [
                                "doctor": "sample",
                                "patient": "sample",
                            ]
                            
                            // use batched write
                            let batch = self.db.batch()
                            for (key, value) in dataEntries {
                                let dataDocRef = dataCollectionRef.document(key)
                                batch.setData(["value": value], forDocument: dataDocRef)
                            }
                            
                            batch.commit { err in
                                if let err = err {
                                    print("Error adding data to 'data' collection: \(err)")
                                } else {
                                    print("Data successfully added to 'data' collection")
                                }
                                completion(newConversation)
                            }
                        }
                    }
                }
            }
        }
    }
}

