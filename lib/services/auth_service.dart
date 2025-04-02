import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'pocketbase_client.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(event.record == null
              ? null
              : User.fromJson(event.record!.toJson()));
        });
      });
    }
  }

  Future<User> signup(String email, String password) async {
    final pb = await getPocketbaseInstance();
    try {
      final record = await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
      });
      return User.fromJson(record.toJson());
    } catch (error) {
      throw Exception('Failed to signup');
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();
    try {
      final authRecord =
          await pb.collection('users').authWithPassword(email, password);
      return User.fromJson(authRecord.record.toJson());
    } catch (error) {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  Future<User?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final model = pb.authStore.record;

    if (model == null) return null;
    return User.fromJson(model.toJson());
  }

  String _getFeaturedImageUrl(PocketBase pb, RecordModel userModel) {
    final featuredImageName = userModel.getStringValue('avatar');
    return pb.files.getUrl(userModel, featuredImageName).toString();
  }

  Future<User?> updateUser(User user) async {
    try {
      final pb = await getPocketbaseInstance();

      final userModel = await pb.collection('users').update(
            user.id,
            body: user.toJson(),
            files: user.avatar != null
                ? [
                    http.MultipartFile.fromBytes(
                      'avatar',
                      await user.avatar!.readAsBytes(),
                      filename: user.avatar!.uri.pathSegments.last,
                    ),
                  ]
                : [],
          );

      return user.copyWith(
        imageUrl: user.avatar != null
            ? _getFeaturedImageUrl(pb, userModel)
            : user.imageUrl,
      );
    } catch (error) {
      print('Error updating user: $error');
      return null;
    }
  }

  Future<User?> getUserDetails() async {
    final pb = await getPocketbaseInstance();
    final record = pb.authStore.model;

    if (record == null) return null;

    // Lấy dữ liệu người dùng đầy đủ và ảnh đại diện
    final imageUrl = pb.files.getUrl(record, record.getStringValue('avatar'));

    return User.fromJson({
      ...record.toJson(),
      'imageUrl': imageUrl.toString(),
    });
  }
}
