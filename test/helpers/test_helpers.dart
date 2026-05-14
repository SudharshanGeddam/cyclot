import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> createMockDoc(
  Map<String, dynamic> data,
  String id,
) async {
  final fake = FakeFirebaseFirestore();
  await fake.collection('test').doc(id).set(data);
  return await fake.collection('test').doc(id).get();
}
