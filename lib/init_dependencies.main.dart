part of 'init_dependencies.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> initDependencies() async {
  // supabase
  final sb = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  sl.registerLazySingleton<SupabaseClient>(() => sb.client);

  // core - user
  sl.registerLazySingleton(() => AppUserCubit());

  // core - network
  sl.registerFactory(() => InternetConnection());
  sl.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(internetConnection: sl()),
  );

  // local data source from Hive
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  sl.registerLazySingleton(() => Hive.box('blogs'));

  // features - auth
  _initAuth();
  _initBlog();
}

void _initAuth() {
  sl
    // data layer - data sources
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sbClient: sl()),
    )
    // domain layer - repositories (implementation belongs to data layer)
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        connectionChecker: sl(),
        authRemoteDataSource: sl(),
      ),
    )
    // domain layer - use cases
    ..registerFactory(() => UserSignUp(authRepository: sl()))
    ..registerFactory(() => UserLogin(authRepository: sl()))
    ..registerFactory(() => CurrentUser(authRepository: sl()))
    // presentation layer - bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: sl(),
        userLogin: sl(),
        currentUser: sl(),
        appUserCubit: sl(),
      ),
    );
}

void _initBlog() {
  sl
    // data layer - data sources
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(sbClient: sl()),
    )
    ..registerFactory<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(box: sl()),
    )
    // domain layer - repositories (implementation belongs to data layer)
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        connectionChecker: sl(),
        blogLocalDataSource: sl(),
        blogRemoteDataSource: sl(),
      ),
    )
    // domain layer - use cases
    ..registerFactory(() => UploadBlog(blogRepository: sl()))
    ..registerFactory(() => GetAllBlogs(blogRepository: sl()))
    // presentation layer - bloc
    ..registerLazySingleton(
      () => BlogBloc(uploadBlog: sl(), getAllBlogs: sl()),
    );
}
