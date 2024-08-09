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

    func addData(collection: String, data: [String: Any]) {
        db.collection(collection).addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added successfully")
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
}

