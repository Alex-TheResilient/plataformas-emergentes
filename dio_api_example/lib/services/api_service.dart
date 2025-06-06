import 'package:dio/dio.dart';
import '../models/post.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => print('API Log: $obj'),
      ),
    );

    // Interceptor para manejo de errores
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('Error interceptado: ${error.message}');
          handler.next(error);
        },
        onRequest: (options, handler) {
          print('Realizando petición a: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('Respuesta recibida: ${response.statusCode}');
          handler.next(response);
        },
      ),
    );
  }

  // GET: Obtener todos los posts
  Future<List<Post>> getAllPosts() async {
    try {
      final response = await _dio.get('/posts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Error al obtener posts: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Error Dio: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error general: $e');
      rethrow;
    }
  }

  // GET: Obtener un post específico por ID
  Future<Post> getPostById(int id) async {
    try {
      final response = await _dio.get('/posts/$id');

      if (response.statusCode == 200) {
        return Post.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Error al obtener post $id: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Error Dio: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error general: $e');
      rethrow;
    }
  }

  // POST: Crear un nuevo post
  Future<Post> createPost(Post post) async {
    try {
      final response = await _dio.post('/posts', data: post.toJson());

      if (response.statusCode == 201) {
        return Post.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Error al crear post: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Error Dio: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error general: $e');
      rethrow;
    }
  }

  // DELETE: Eliminar un post
  Future<bool> deletePost(int id) async {
    try {
      final response = await _dio.delete('/posts/$id');

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error Dio: ${e.message}');
      return false;
    } catch (e) {
      print('Error general: $e');
      return false;
    }
  }
}
