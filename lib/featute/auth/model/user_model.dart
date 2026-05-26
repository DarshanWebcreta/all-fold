class LoginResponseModel {
  bool? success;
  LoginData? data;
  String? message;

  LoginResponseModel({this.success, this.data, this.message});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? LoginData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class LoginData {
  String? token;
  UserModel? user;

  LoginData({this.token, this.user});

  LoginData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserModel {
  int? id;
  String? name;
  String? email;
  bool? isAdmin;
  int? warehouseId;
  String? warehouseName;
  List<String>? roles;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.isAdmin,
    this.warehouseId,
    this.warehouseName,
    this.roles,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    isAdmin = json['is_admin'] is int ? (json['is_admin'] == 1) : json['is_admin'];
    warehouseId = json['warehouse_id'];
    warehouseName = json['warehouse_name'];
    if (json['roles'] != null) {
      roles = List<String>.from(json['roles']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['is_admin'] = isAdmin;
    data['warehouse_id'] = warehouseId;
    data['warehouse_name'] = warehouseName;
    if (roles != null) {
      data['roles'] = roles;
    }
    return data;
  }
}

class ProfileResponseModel {
  bool? success;
  ProfileData? data;
  String? message;

  ProfileResponseModel({this.success, this.data, this.message});

  ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class ProfileData {
  UserModel? user;

  ProfileData({this.user});

  ProfileData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
