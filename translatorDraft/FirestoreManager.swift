//
//  FireStoreManager.swift
//  translatorDraft
//
//  Created by Aman Sahu on 8/9/24.
//

import FirebaseFirestore
import Combine

class FirestoreManager: ObservableObject {
    private var db = Firestore.firestore()
    
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

