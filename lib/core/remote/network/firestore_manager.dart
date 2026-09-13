import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:evently_c19/model/user.dart';

import '../../../model/event.dart';


class FirestoreManager {
  static CollectionReference<User> getUserCollection() {
    var collection = FirebaseFirestore.instance
        .collection("User")
        .withConverter(
      fromFirestore: (snapshot, options) {
        var data = snapshot.data();
        return User.fromFireStore(data);
      },
      toFirestore: (value, options) {
        return value.toFirestore();
      },
    );
    return collection;
  }

  static Future<void> saveUser(User user) {
    var collection = getUserCollection();
    var document = collection.doc(auth.FirebaseAuth.instance.currentUser!.uid);
    return document.set(user);
  }

  static Future<User?> getUser() async {
    var collection = getUserCollection();
    var doc = collection.doc(auth.FirebaseAuth.instance.currentUser!.uid);
    var docSnapshot = await doc.get();
    var user = docSnapshot.data();
    return user;
  }

  static CollectionReference<Event> getEventCollection() {
    var collection = FirebaseFirestore.instance
        .collection("Event")
        .withConverter(
      fromFirestore: (snapshot, options) {
        var data = snapshot.data();
        return Event.fromFirestore(data);
      },
      toFirestore: (event, options) {
        return event.toFirestore();
      },
    );
    return collection;
  }

  static Future<void> addEvent(Event event){
    var collection = getEventCollection();
    var doc = collection.doc();
    event.id = doc.id;
    return doc.set(event);
  }

  static Future<void> updateEvent(Event event) {
    var collection = getEventCollection();
    var docRef = collection.doc(event.id);
    return docRef.set(event);
  }

  static Future<List<Event>> getAllEvents()async{
    var collection = getEventCollection();
    var querySnapshot = await collection.get();
    var docsList = querySnapshot.docs;
    var eventList = docsList.map((doc) => doc.data(),).toList();
    return eventList;
  }

  static Stream<List<Event>> getAllEventsRealTime()async*{
    var collection = getEventCollection();
    var querySnapshotStream = collection.snapshots();
    var docsStream = querySnapshotStream.map((querySnapshot) => querySnapshot.docs,);
    var eventsStream = docsStream.map((docs) => docs.map((document) => document.data(),).toList(),);
    yield* eventsStream;
  }

  static Future<List<Event>> getFilteredEvents(String type)async{
    var collection = getEventCollection().where("type",isEqualTo: type);
    var querySnapshot = await collection.get();
    var docsList = querySnapshot.docs;
    var eventList = docsList.map((doc) => doc.data(),).toList();
    return eventList;
  }

  static CollectionReference<Event> getFavoritesCollection(){
    var userCollection = getUserCollection();
    var userDoc = userCollection.doc(auth.FirebaseAuth.instance.currentUser!.uid);
    var collection = userDoc.collection("Favorite").withConverter(
      fromFirestore: (snapshot, options) {
        var data = snapshot.data();
        return Event.fromFirestore(data);
      },
      toFirestore: (event, options) {
        return event.toFirestore();
      },
    );
    return collection;
  }

  static Future<void> addFavoriteEvent(Event event){
    var collection = getFavoritesCollection();
    var docRef = collection.doc(event.id);
    return docRef.set(event);
  }

  static Future<void> deleteFavoriteEvent(Event event){
    var collection = getFavoritesCollection();
    var docRef = collection.doc(event.id);
    return docRef.delete();
  }

  static Stream<List<Event>> getFavoritesList()async*{
    var collection = getFavoritesCollection();
    var querySnapshotStream = collection.snapshots();
    var docsStream = querySnapshotStream.map((querySnapshot) => querySnapshot.docs,);
    var eventsStream = docsStream.map((docs) => docs.map((document) => document.data(),).toList(),);
    yield* eventsStream;
  }

  static Future<void> updateUserFavorites(List<String> favorites){
    var collection = getUserCollection();
    var doc = collection.doc(auth.FirebaseAuth.instance.currentUser!.uid);
    return doc.update({"favorites":favorites});
  }
}