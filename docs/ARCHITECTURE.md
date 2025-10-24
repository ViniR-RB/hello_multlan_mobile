# Arquitetura do Projeto Hello Multlan

Este documento descreve a arquitetura do projeto **Hello Multlan**, que segue o padrão **App Architecture** apresentado pelo Google para Flutter.

## Visão Geral

A arquitetura é dividida em **três camadas principais**:

1. **UI Layer** (Camada de Interface)
2. **Logic Layer** (Camada de Lógica de Negócio)
3. **Data Layer** (Camada de Dados)

Além disso, o projeto é **modularizado** usando Flutter Modular, com módulos separados para diferentes funcionalidades.

---

## 1. UI Layer (Camada de Interface)

A UI Layer é responsável por apresentar os dados ao usuário e capturar as interações. Ela é composta por três componentes principais:

### 1.1 Page (Página)

É a **interface visual de fato** - os widgets Flutter que compõem a tela.

**Exemplo:**
```dart
// lib/app/ui/login/login_page.dart
class LoginPage extends StatefulWidget {
  final LoginController controller;
  final LoginCommand loginCommand;
  
  const LoginPage({
    required this.controller,
    required this.loginCommand,
  });
}
```

A página:
- Renderiza a UI
- Escuta mudanças nos Commands
- Apresenta feedback visual (loaders, mensagens de erro/sucesso)
- Delega ações para o ViewModel/Controller

### 1.2 ViewModel / Controller

O **ViewModel** (ou Controller) controla o **estado da página** e faz o **binding** entre a UI e as camadas inferiores (Logic ou Data Layer).

**Exemplo:**
```dart
// lib/app/modules/box/ui/box_map/box_map_controller.dart
class BoxMapController {
  final GetBoxesByFiltersCommand _getBoxesByFiltersCommand;
  final WatchUserPositionCommand _watchUserPositionCommand;

  BoxMapController({
    required GetBoxesByFiltersCommand getBoxesByFiltersCommand,
    required WatchUserPositionCommand watchUserPositionCommand,
  }) : _getBoxesByFiltersCommand = getBoxesByFiltersCommand,
       _watchUserPositionCommand = watchUserPositionCommand;

  Future<void> watchUserPosition() => _watchUserPositionCommand.execute();
  
  void fetchInitialBoxes() {
    _fetchBoxesForCurrentView();
  }
}
```

O Controller:
- Recebe Commands como dependências
- Expõe métodos públicos para a Page invocar
- Orquestra a execução dos Commands
- Não contém lógica de negócio complexa

### 1.3 Command

O **Command** é um padrão que **liga a Page ao ViewModel**. Ele gerencia seu próprio estado usando **ChangeNotifier** e segue o padrão **State Machine** através do `CommandState`.

#### Base Command

```dart
// lib/app/core/base_command.dart
abstract class BaseCommand<S, F> extends ChangeNotifier {
  CommandState<S, F> _state;
  bool _isDisposed = false;

  BaseCommand(this._state);

  CommandState<S, F> get state => _state;

  @protected
  void setState(CommandState<S, F> newState) {
    if (_isDisposed == true) return;
    _state = newState;
    notifyListeners();
  }

  void reset();
}
```

#### Command State

O estado do Command pode ser:
- **CommandInitial** - Estado inicial
- **CommandLoading** - Executando operação
- **CommandSuccess** - Operação bem-sucedida
- **CommandFailure** - Operação falhou

```dart
// lib/app/core/states/command_state.dart
sealed class CommandState<T extends dynamic, AppException> {}

final class CommandInitial<T, AppException> extends CommandState<T, AppException> {
  final T value;
  CommandInitial(this.value);
}

final class CommandLoading<T, AppException> extends CommandState<T, AppException> {}

final class CommandSuccess<T, AppException> extends CommandState<T, AppException> {
  final T value;
  CommandSuccess(this.value);
}

final class CommandFailure<T, AppException> extends CommandState<T, AppException> {
  final AppException exception;
  CommandFailure(this.exception);
}
```

#### Exemplo de Command Concreto

```dart
// lib/app/modules/auth/ui/user_profile/commands/who_i_am_command.dart
class WhoIAmCommand extends BaseCommand<UserModel?, AppException> {
  final AuthRepository _authRepository;

  WhoIAmCommand(this._authRepository) : super(CommandInitial(null));

  Future<void> execute() async {
    setState(CommandLoading());

    final result = await _authRepository.whoIAm();

    result.when(
      onSuccess: (user) => setState(CommandSuccess(user)),
      onFailure: (exception) => setState(CommandFailure(exception)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
```

#### Uso do Command na Page

```dart
// Na Page, escutamos o Command
@override
void initState() {
  super.initState();
  widget.loginCommand.addListener(_listenerLogin);
}

_listenerLogin() {
  final state = widget.loginCommand.state;

  if (state is CommandLoading) {
    notifier.showLoader();
  }

  if (state case CommandFailure(exception: final exception)) {
    notifier.hideLoader();
    notifier.showMessage(
      translateError(context, exception.code),
      SnackType.error,
    );
  }

  if (state is CommandSuccess) {
    notifier.hideLoader();
    notifier.showMessage(
      translateSuccess(context, "successInLogin"),
      SnackType.success,
    );
    Modular.to.navigate("/box/");
  }
}
```

### 1.4 DTOs (Data Transfer Objects)

Os **DTOs** são objetos usados para transferir dados entre as camadas. No projeto, os DTOs têm duas características importantes:

1. **Estendem `ChangeNotifier`** para serem reativos
2. **Usam [LucidValidation](https://pub.dev/packages/lucid_validation)** para validação de dados

#### DTO Reativo

Os DTOs estendem `ChangeNotifier` para permitir que a UI reaja a mudanças nos seus valores.

**Exemplo: Credentials DTO**
```dart
// lib/app/modules/auth/dtos/credentials.dart
import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';

class Credentials extends ChangeNotifier {
  String email;
  String password;

  Credentials({
    this.email = "",
    this.password = "",
  });

  setEmail(String value) {
    email = value;
    notifyListeners();  // Notifica listeners sobre mudança
  }

  setPassword(String value) {
    password = value;
    notifyListeners();  // Notifica listeners sobre mudança
  }
}
```

**Exemplo: CreateBoxDto**
```dart
// lib/app/modules/box/dto/create_box_dto.dart
class CreateBoxDto extends ChangeNotifier {
  String label;
  String latitude;
  String longitude;
  int freeSpace;
  num signal;
  List<String> listUser;
  File? image;

  int get filledSpace => listUser.length;

  CreateBoxDto({
    this.label = "",
    this.latitude = "",
    this.longitude = "",
    this.freeSpace = 0,
    this.signal = 0.0,
    List<String>? listUser,
    this.image,
  }) : listUser = List<String>.from(listUser ?? []);

  set setLabel(String value) {
    label = value;
    notifyListeners();
  }

  set setFreeSpace(int value) {
    freeSpace = value;
    notifyListeners();
  }

  void addUserForListValue(String value, int index) {
    listUser[index] = value;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'freeSpace': freeSpace,
      'signal': signal,
      'listUser': listUser,
      // ... outros campos
    };
  }
}
```

#### Validação com LucidValidation

O projeto usa **[LucidValidation](https://pub.dev/packages/lucid_validation)** para validação de DTOs. LucidValidation é um pacote Dart/Flutter inspirado no FluentValidation, oferecendo uma API fluente e fortemente tipada.

**Criando um Validator:**

```dart
// lib/app/modules/auth/dtos/credentials.dart
class CredentialsValidator extends LucidValidator<Credentials> {
  CredentialsValidator() {
    ruleFor(
      (credentials) => credentials.email,
      key: 'email',
    ).notEmpty().validEmail();

    ruleFor(
      (credentials) => credentials.password,
      key: 'password',
    ).notEmpty().minLength(6);
  }
}
```

**Exemplo mais complexo:**

```dart
// lib/app/modules/box/dto/create_box_dto.dart
class CreateBoxDtoValidator extends LucidValidator<CreateBoxDto> {
  CreateBoxDtoValidator() {
    ruleFor((box) => box.label, key: "label")
      .notEmpty()
      .minLength(3);

    ruleFor((box) => box.latitude, key: "latitude")
      .notEmpty();

    ruleFor((box) => box.longitude, key: "longitude")
      .notEmpty();

    ruleFor((box) => box.freeSpace, key: "freeSpace")
      .greaterThan(1);

    // Validação customizada com mustWith
    ruleFor((box) => box.filledSpace, key: "filledSpace")
      .mustWith(
        (filled, box) => filled <= box.freeSpace,
        "filledSpaceGreaterThanFreeSpace",
        "filledSpaceGreaterThanFreeSpace",
      );

    ruleFor((box) => box.note, key: "note")
      .mustWith(
        (note, box) => note.isEmpty || note.length > 3,
        "noteMinLength",
        "noteMinLength",
      );

    // Validação condicional com when
    ruleFor((box) => box.address, key: "address")
      .notEmpty()
      .minLength(3)
      .when((box) => box.gpsMode == "ADDRESS");

    ruleFor((box) => box.image, key: "image")
      .isNotNull();

    // Validação de lista com setEach
    ruleFor((box) => box.listUser, key: "listUser")
      .setEach(SimpleUserValidator());
  }
}

class SimpleUserValidator extends LucidValidator<String> {
  SimpleUserValidator() {
    ruleFor((value) => value, key: "simpleUser")
      .notEmpty()
      .minLength(4);
  }
}
```

#### Uso em TextFormField com `byField`

O método `byField` permite usar validators diretamente em `TextFormField`:

```dart
class LoginPage extends StatelessWidget {
  final validator = CredentialsValidator();
  final credentials = Credentials();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(hintText: 'Email'),
            onChanged: credentials.setEmail,
            validator: validator.byField(credentials, 'email'),
          ),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Password'),
            onChanged: credentials.setPassword,
            validator: validator.byField(credentials, 'password'),
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
```

#### Validação Programática

Você também pode validar programaticamente:

```dart
final dto = CreateBoxDto(
  label: 'Label',
  latitude: '10.0',
  longitude: '20.0',
  freeSpace: 5,
  signal: 2,
  listUser: ['user1'],
  image: File("path"),
);

final validator = CreateBoxDtoValidator();
final result = validator.validate(dto);

if (result.isValid) {
  // DTO válido
  print('DTO is valid');
} else {
  // DTO inválido
  for (var exception in result.exceptions) {
    print('${exception.key}: ${exception.message}');
  }
}
```

#### Benefícios dos DTOs Reativos

1. **UI Reativa**: A UI atualiza automaticamente quando o DTO muda
2. **Validação em Tempo Real**: Pode validar enquanto o usuário digita
3. **Binding Bidirecional**: Mudanças na UI refletem no DTO e vice-versa
4. **Código Limpo**: Separação clara entre dados e lógica

**Exemplo de uso com ListenableBuilder:**

```dart
final credentials = Credentials();
final validator = CredentialsValidator();

ListenableBuilder(
  listenable: credentials,
  builder: (context, child) {
    final isValid = validator.validate(credentials).isValid;
    
    return ElevatedButton(
      onPressed: isValid ? () => submit() : null,
      child: Text("Entrar"),
    );
  },
)
```

#### Validações Disponíveis

O LucidValidation oferece diversos validators:

- **String**: `notEmpty()`, `minLength()`, `maxLength()`, `validEmail()`, `matchesPattern()`
- **Number**: `greaterThan()`, `lessThan()`, `min()`, `max()`, `range()`
- **Custom**: `must()`, `mustWith()` (com acesso à entidade completa)
- **Conditional**: `when()` (validação condicional)
- **Complex**: `setValidator()` (validação de objetos aninhados), `setEach()` (validação de listas)
- **Null**: `isNull()`, `isNotNull()`, `*OrNull` (versões que aceitam null)

**Validações customizadas:**

```dart
extension CustomValidations on SimpleValidationBuilder<String> {
  SimpleValidationBuilder<String> customValidPhone() {
    return use((value, entity) {
      final regex = RegExp(r'^\(?(\d{2})\)?\s?9?\d{4}-?\d{4}$');
      
      if (regex.hasMatch(value)) {
        return null;
      }

      return ValidationException(
        message: "Telefone inválido",
        code: "invalidPhone",
        key: key,
      );
    });
  }
}
```

---

### 1.5 Loader e Tratamento de Erros

#### LoaderMessageMixin

O `LoaderMessageMixin` fornece funcionalidades para mostrar loaders e mensagens de sucesso/erro.

```dart
// lib/app/core/extensions/loader_message.dart
mixin LoaderMessageMixin<T extends StatefulWidget> on State<T> {
  late LoaderMessageNotifier notifier;
  
  @override
  void initState() {
    super.initState();
    notifier = LoaderMessageNotifier();
    notifier.addListener(_handleNotifier);
  }

  void _handleNotifier() {
    if (!mounted) return;

    // Mostra loader quando isLoading é true
    if (notifier.isLoading && !_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        builder: (_) => LoadingAnimationWidget.threeArchedCircle(
          color: Colors.blue,
          size: 60,
        ),
        barrierDismissible: false,
      );
    }
    
    // Esconde loader
    else if (!notifier.isLoading && _isDialogOpen) {
      _isDialogOpen = false;
      Modular.to.pop();
    }

    // Mostra mensagens (erro, sucesso, info)
    if (notifier.message != null && notifier.type != null) {
      // Mostra TopSnackBar baseado no tipo
    }
  }
}
```

**Uso na Page:**
```dart
class _LoginPageState extends State<LoginPage>
    with ErrorTranslator, SuccessTranslator, LoaderMessageMixin {
  
  _listenerLogin() {
    if (state is CommandLoading) {
      notifier.showLoader();  // Mostra loader
    }
    
    if (state case CommandFailure(exception: final exception)) {
      notifier.hideLoader();  // Esconde loader
      notifier.showMessage(   // Mostra mensagem de erro
        translateError(context, exception.code),
        SnackType.error,
      );
    }
  }
}
```

#### ErrorTranslator Mixin

O `ErrorTranslator` traduz códigos de erro para mensagens amigáveis usando i18n (l10n).

```dart
// lib/app/core/extensions/error_translator.dart
mixin ErrorTranslator<T extends StatefulWidget> on State<T> {
  String translateError(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (code) {
      case "networkError":
        return l10n.networkError;
      case "invalidCredentials":
        return l10n.invalidCredentials;
      case "locationServiceDisabled":
        return l10n.locationServiceDisabled;
      case "timeout":
        return l10n.timeout;
      default:
        return l10n.unknownError;
    }
  }
}
```

---

## 2. Logic Layer (Camada de Lógica)

A Logic Layer contém os **Use Cases** (Casos de Uso).

### 2.1 Use Cases

Use Cases são utilizados quando há **lógica de negócio complexa** que precisa ser **isolada do consumo de dados**.

**Quando usar:**
- Quando há regras de negócio que envolvem múltiplos repositories
- Quando há validações ou transformações complexas de dados
- Quando a mesma lógica é reutilizada em diferentes partes da aplicação

**Estrutura:**
```dart
// Exemplo conceitual de Use Case
class CreateBoxUseCase {
  final BoxRepository _boxRepository;
  final GeoLocatorRepository _geoLocatorRepository;
  
  CreateBoxUseCase({
    required BoxRepository boxRepository,
    required GeoLocatorRepository geoLocatorRepository,
  }) : _boxRepository = boxRepository,
       _geoLocatorRepository = geoLocatorRepository;

  AsyncResult<AppException, Unit> execute(BoxData data) async {
    // Lógica de negócio complexa aqui
    // 1. Validar coordenadas
    // 2. Verificar permissões
    // 3. Transformar dados
    // 4. Criar box
    
    return await _boxRepository.createBox(data);
  }
}
```

**Nota:** No projeto atual, em muitos casos os Commands chamam diretamente os Repositories. Use Cases são introduzidos quando a complexidade da lógica de negócio justifica a separação.

---

## 3. Data Layer (Camada de Dados)

A Data Layer é responsável por **acessar e gerenciar dados**. Ela implementa o princípio de **Single Source of Truth** (SSOT).

### 3.1 Repositories

Os **Repositories** são a **fonte única de verdade** (Single Source of Truth). Eles:
- Definem a interface para acesso aos dados
- Implementam a lógica para coordenar diferentes fontes de dados
- Retornam `Either<AppException, T>` para tratamento de erros

#### Interface do Repository

```dart
// lib/app/modules/box/repositories/box_repository.dart
abstract interface class BoxRepository {
  AsyncResult<AppException, List<BoxLiteModel>> getAllBoxesByFilters({
    required double latMin,
    required double lngMin,
    required double latMax,
    required double lngMax,
    String? zone,
  });
  
  AsyncResult<AppException, File> getImageFromGallery();
  AsyncResult<AppException, File> getImageFromCamera();
  AsyncResult<AppException, Unit> createBox(CreateBoxDto box);
  AsyncResult<AppException, BoxModel> getBoxById(String id);
}
```

#### Implementação do Repository

```dart
// lib/app/modules/box/repositories/box_repository_impl.dart
class BoxRepositoryImpl implements BoxRepository {
  final BoxGateway _gateway;                    // API calls
  final ImagePickerService _imagePickerService; // Serviço de câmera
  
  BoxRepositoryImpl({
    required BoxGateway gateway,
    required ImagePickerService imagePickerService,
  }) : _gateway = gateway,
       _imagePickerService = imagePickerService;

  @override
  AsyncResult<AppException, List<BoxLiteModel>> getAllBoxesByFilters({
    required double latMin,
    required double lngMin,
    required double latMax,
    required double lngMax,
    String? zone,
  }) async {
    try {
      final listBoxResult = await _gateway.getAllBoxesByFilters(
        latMin, lngMin, latMax, lngMax, zone,
      );
      return Success(listBoxResult);
    } catch (e, s) {
      throw BoxRepositoryException("unknownError", e.toString(), s);
    }
  }

  @override
  AsyncResult<AppException, File> getImageFromGallery() async {
    return await _imagePickerService.pickFromGallery();
  }
}
```

### 3.2 Gateways (API Calls)

Os **Gateways** são responsáveis por fazer **chamadas de API**. O projeto usa **Retrofit** + **Dio**.

```dart
// lib/app/modules/box/gateway/box_gateway.dart
@RestApi()
abstract class BoxGateway {
  factory BoxGateway(Dio dio, {String baseUrl}) = _BoxGateway;

  @GET("/api/box/")
  @Headers({'DIO_AUTH_KEY': true})
  Future<List<BoxLiteModel>> getAllBoxesByFilters(
    @Query("latMin") double latMin,
    @Query("lngMin") double lngMin,
    @Query("latMax") double latMax,
    @Query("lngMax") double lngMax,
    @Query("zone") String? zone,
  );

  @POST("/api/box")
  @Headers({'DIO_AUTH_KEY': true})
  @MultiPart()
  Future<void> createBox(@Part() Map<String, dynamic> data);

  @GET("/api/box/{id}")
  @Headers({'DIO_AUTH_KEY': true})
  Future<BoxModel> getBoxById(@Path("id") String id);
}
```

### 3.3 Services (Serviços)

Os **Services** encapsulam funcionalidades específicas:
- **LocalStorage** - Armazenamento local seguro
- **GeoLocator** - GPS/Localização
- **ImagePicker** - Câmera/Galeria
- **PushNotification** - Notificações push
- **LocalNotification** - Notificações locais

#### Exemplo: LocalStorageService

```dart
// lib/app/core/data/local_storage/local_storage_service_impl.dart
class LocalStorageServiceImpl implements ILocalStorageService {
  final FlutterSecureStorage _storage;

  LocalStorageServiceImpl({required FlutterSecureStorage storage})
    : _storage = storage;

  @override
  AsyncResult<AppException, String> get(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) {
        return Failure(LocalStorageNotFoundException());
      }
      return Success(value);
    } catch (e, s) {
      throw LocalStorageException("unknownError", e.toString(), s);
    }
  }

  @override
  AsyncResult<AppException, Unit> set(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return Success(unit);
    } catch (e, s) {
      throw LocalStorageException("unknownError", e.toString(), s);
    }
  }
}
```

#### Uso de Services nos Repositories

```dart
class OccurrenceRepositoryImpl implements OccurrenceRepository {
  final OccurrenceGateway _gateway;            // API
  final ILocalStorageService _localStorageService;  // Local Storage

  @override
  AsyncResult<AppException, PageModel<OccurrenceModel>> getUserOccurrences({
    int page = 1,
    int take = 10,
  }) async {
    // Busca usuário do local storage
    final userModelResult = await _localStorageService.get(Constants.userKey);
    final userModelString = userModelResult.getOrThrow();
    final userModel = UserModel.fromJson(jsonDecode(userModelString));
    
    // Busca ocorrências da API
    final pageOccurrenceLit = await _gateway.getAllOccurences(
      take, page, userModel.id, "DESC",
    );
    
    return Success(pageOccurrenceLit);
  }
}
```

---

## 4. Tratamento de Erros com Either

O projeto usa o padrão **Either** para tratamento de erros funcional.

### 4.1 Either

```dart
// lib/app/core/either/either.dart
sealed class Either<L extends AppException, R> {
  R getOrThrow();
  
  bool get isSuccess => this is Success<L, R>;
  bool get isFailure => this is Failure<L, R>;

  W when<W>({
    required W Function(R value) onSuccess,
    required W Function(L exception) onFailure,
  });
}

final class Success<L extends AppException, R> extends Either<L, R> {
  final R _value;
  Success(this._value);
}

final class Failure<L extends AppException, R> extends Either<L, R> {
  final L _exception;
  Failure(this._exception);
}
```

### 4.2 AppException

As exceções do projeto usam um **código (code)** para permitir tradução i18n.

```dart
// lib/app/core/exceptions/app_exception.dart
class AppException implements Exception {
  final String code;
  String? message;
  StackTrace? stackTrace;

  AppException(this.code, [this.message, this.stackTrace]);
}
```

**Exemplos de códigos:**
- `"networkError"` - Erro de rede
- `"invalidCredentials"` - Credenciais inválidas
- `"timeout"` - Timeout
- `"locationPermissionDenied"` - Permissão de localização negada
- `"unknownError"` - Erro desconhecido

### 4.3 AsyncResult e StreamResult

```dart
// lib/app/core/extensions/async_result_extension.dart
typedef AsyncResult<L extends AppException, R> = Future<Either<L, R>>;

extension AsyncResultExtension<L extends AppException, R> on AsyncResult<L, R> {
  // Transforma o valor de sucesso
  AsyncResult<L, W> map<W>(FutureOr<W> Function(R success) fn);
  
  // Flatten nested AsyncResult
  AsyncResult<L, T> flatMap<T>(AsyncResult<L, T> Function(R value) mapper);
  
  // Pattern matching
  Future<W> when<W>({
    required W Function(R value) onSuccess,
    required W Function(L exception) onFailure,
  });
}
```

**Exemplo de uso:**
```dart
final result = await _authRepository.whoIAm();

result.when(
  onSuccess: (user) => setState(CommandSuccess(user)),
  onFailure: (exception) => setState(CommandFailure(exception)),
);
```

---

## 5. Modularização

O projeto está dividido em **módulos** usando **Flutter Modular**.

### 5.1 Estrutura de Módulos

```
lib/app/
  ├── app_module.dart        # Módulo principal
  ├── core/                  # Módulo Core (compartilhado)
  │   └── core_module.dart
  ├── modules/
  │   ├── auth/              # Módulo de Autenticação
  │   │   └── auth_module.dart
  │   ├── box/               # Módulo de Boxes
  │   │   └── box_module.dart
  │   ├── occurrence/        # Módulo de Ocorrências
  │   │   └── occurrence_module.dart
  │   └── geo_locator/       # Módulo de Geolocalização
  │       └── geo_locator_module.dart
```

### 5.2 Core Module

O **CoreModule** fornece **serviços compartilhados** para toda a aplicação.

```dart
// lib/app/core/core_module.dart
class CoreModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // HTTP Client
    i.addLazySingleton(RestClient.new);
    
    // Local Storage
    i.addLazySingleton<ILocalStorageService>(
      () => LocalStorageServiceImpl(
        storage: FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
      ),
    );
    
    // Serviços de dispositivo
    i.addLazySingleton<ImagePickerService>(ImagePickerServiceImpl.new);
    i.addLazySingleton<NavigationService>(NavigationServiceImpl.new);
    i.addLazySingleton<PushNotification>(PushNotificationImpl.new);
    i.addLazySingleton<LocalNotification>(LocalNotificationImpl.new);
    
    // Auth (usado por todos os módulos)
    i.addLazySingleton<AuthRepository>(AuthRepositoryImpl.new);
    i.addLazySingleton(() => AuthGateway(i.get<RestClient>()));
  }
}
```

### 5.3 Feature Modules (Módulos de Funcionalidade)

#### AuthModule

```dart
// lib/app/modules/auth/auth_module.dart
class AuthModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    // Commands
    i.addLazySingleton(ResetPasswordCommand.new);
    i.addLazySingleton(WhoIAmCommand.new);
    
    // Controller
    i.addLazySingleton(UserProfileController.new);
  }

  @override
  void exportedBinds(Injector i) {
    // Commands exportados para outros módulos
    i.addLazySingleton(UserLogged.new);
    i.addLazySingleton(LoginCommand.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/profile', child: (context) => UserProfilePage(...));
  }
}
```

#### BoxModule

```dart
// lib/app/modules/box/box_module.dart
class BoxModule extends Module {
  @override
  List<Module> get imports => [
    CoreModule(),
    AuthModule(),
    GeoLocatorModule(),
  ];

  @override
  void binds(Injector i) {
    // Repository
    i.addLazySingleton<BoxRepository>(BoxRepositoryImpl.new);
    
    // Gateway
    i.addLazySingleton(() => BoxGateway(Modular.get<RestClient>()));

    // Commands
    i.add(GetBoxesByFiltersCommand.new);
    i.add(GetImageCommand.new);
    i.add(CreateBoxDataCommand.new);
    i.add(UpdateBoxDataCommand.new);
  }

  @override
  void routes(RouteManager r) {
    r.child("/", child: (_) => BoxHubPage(...));
    r.child("/form", child: (_) => BoxFormPage(...));
    r.child("/map", child: (_) => BoxMapPage(...));
    r.child("/edit/:id", child: (_) => BoxEditPage(...));
  }
}
```

### 5.4 Organização por Feature

Cada módulo segue a estrutura:

```
modules/box/
  ├── box_module.dart
  ├── dto/                  # Data Transfer Objects
  │   ├── create_box_dto.dart
  │   └── edit_box_dto.dart
  ├── exceptions/           # Exceções específicas
  │   └── box_repository_exception.dart
  ├── gateway/              # API Gateway
  │   └── box_gateway.dart
  ├── repositories/         # Repositories
  │   ├── box_repository.dart
  │   ├── box_repository_impl.dart
  │   └── models/           # Modelos de domínio
  │       ├── box_model.dart
  │       └── box_lite_model.dart
  └── ui/                   # UI Components
      ├── box_form/
      │   ├── box_form_page.dart
      │   ├── box_form_controller.dart
      │   └── commands/
      │       ├── create_box_data_command.dart
      │       └── get_image_command.dart
      ├── box_map/
      │   ├── box_map_page.dart
      │   ├── box_map_controller.dart
      │   └── command/
      │       └── get_boxes_by_filters_command.dart
      └── box_edit/
          ├── box_edit_page.dart
          ├── box_edit_controller.dart
          └── commands/
              └── update_box_data_command.dart
```

---

## 6. Fluxo de Dados

```
┌─────────────────────────────────────────────────────────────┐
│                         UI LAYER                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐      ┌────────────┐      ┌─────────────┐    │
│  │   Page   │─────>│ Controller │─────>│   Command   │    │
│  │          │<─────│            │<─────│             │    │
│  └──────────┘      └────────────┘      └─────────────┘    │
│       │                                        │            │
│       │ (escuta)                               │            │
│       │                                        │ (executa)  │
│       v                                        v            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │       DTO (ChangeNotifier + LucidValidation)         │  │
│  │              LoaderMessageMixin                      │  │
│  │         (Loader, ErrorTranslator)                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           v
┌─────────────────────────────────────────────────────────────┐
│                      LOGIC LAYER                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                   ┌─────────────┐                           │
│                   │  Use Cases  │ (opcional)                │
│                   │             │                           │
│                   └─────────────┘                           │
│                                                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           v
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────┐    ┌──────────────┐     │
│  │  Repository  │───>│ Gateway  │───>│   API REST   │     │
│  │   (SSOT)     │    │ (Retrofit│    │              │     │
│  │              │    │  + Dio)  │    │              │     │
│  └──────────────┘    └──────────┘    └──────────────┘     │
│         │                                                   │
│         │                                                   │
│         v                                                   │
│  ┌──────────────┐                                          │
│  │   Services   │                                          │
│  │              │                                          │
│  │ • LocalStorage                                          │
│  │ • ImagePicker                                           │
│  │ • GeoLocator                                            │
│  │ • Notifications                                         │
│  └──────────────┘                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘

           ▲                           │
           │                           │
           │    Either<Exception, T>   │
           │                           v
           └───────────────────────────┘
```

---

## 7. Exemplo Completo: Login

### 7.1 Page (UI)

```dart
class LoginPage extends StatefulWidget {
  final LoginController controller;
  final LoginCommand loginCommand;
  
  const LoginPage({
    required this.controller,
    required this.loginCommand,
  });
}

class _LoginPageState extends State<LoginPage>
    with ErrorTranslator, SuccessTranslator, LoaderMessageMixin {
  
  @override
  void initState() {
    super.initState();
    widget.loginCommand.addListener(_listenerLogin);
  }

  _listenerLogin() {
    final state = widget.loginCommand.state;

    if (state is CommandLoading) {
      notifier.showLoader();
    }

    if (state case CommandFailure(exception: final exception)) {
      notifier.hideLoader();
      notifier.showMessage(
        translateError(context, exception.code),
        SnackType.error,
      );
    }

    if (state is CommandSuccess) {
      notifier.hideLoader();
      notifier.showMessage(
        translateSuccess(context, "successInLogin"),
        SnackType.success,
      );
      Modular.to.navigate("/box/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(onChanged: credentials.setEmail),
          TextField(onChanged: credentials.setPassword),
          ElevatedButton(
            onPressed: () => widget.controller.login(credentials),
            child: Text("Entrar"),
          ),
        ],
      ),
    );
  }
}
```

### 7.2 Controller

```dart
class LoginController extends ChangeNotifier {
  final LoginCommand _loginCommand;

  LoginController({required LoginCommand loginCommand})
    : _loginCommand = loginCommand;

  Future<void> login(Credentials credentials) async {
    await _loginCommand.execute(credentials);
  }
}
```

### 7.3 Command

```dart
class LoginCommand extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginCommand({required AuthRepository authRepository})
    : _authRepository = authRepository;

  CommandState<bool?, AppException> _state = CommandInitial(null);
  CommandState<bool?, AppException> get state => _state;

  _setState(CommandState<bool?, AppException> state) {
    _state = state;
    notifyListeners();
  }

  Future<void> execute(Credentials credentials) async {
    _setState(CommandLoading());

    final loginResult = await _authRepository.login(credentials);

    loginResult.when(
      onSuccess: (_) => _setState(CommandSuccess(true)),
      onFailure: (error) => _setState(CommandFailure(error)),
    );
  }
}
```

### 7.4 Repository

```dart
abstract interface class AuthRepository {
  AsyncResult<AppException, Unit> login(Credentials credentials);
  AsyncResult<AppException, bool> isLogged();
  AsyncResult<AppException, UserModel> whoIAm();
}

class AuthRepositoryImpl implements AuthRepository {
  final ILocalStorageService _localStorageService;
  final AuthGateway _authGateway;

  @override
  AsyncResult<AppException, Unit> login(Credentials credentials) async {
    try {
      final response = await _authGateway.login(credentials.toJson());
      
      await _localStorageService.set(
        Constants.accessToken,
        response.accessToken,
      );
      
      return Success(unit);
    } on DioException catch (e, s) {
      if (e.response?.statusCode == 401) {
        return Failure(AuthRepositoryException("invalidCredentials", ...));
      }
      return Failure(AuthRepositoryException("networkError", ...));
    }
  }
}
```

### 7.5 Gateway

```dart
@RestApi()
abstract class AuthGateway {
  factory AuthGateway(Dio dio) = _AuthGateway;

  @POST("/api/auth/login")
  Future<LoginResponse> login(@Body() Map<String, dynamic> credentials);
  
  @GET("/api/auth/me")
  @Headers({'DIO_AUTH_KEY': true})
  Future<UserModel> getMe();
}
```

---

## 8. Boas Práticas

### 8.1 Sempre use Either para operações assíncronas
```dart
// ✅ BOM
AsyncResult<AppException, User> getUser();

// ❌ RUIM
Future<User> getUser(); // Sem tratamento de erro tipado
```

### 8.2 Commands devem ser simples
Commands não devem conter lógica de negócio complexa - apenas orquestração.

### 8.3 Repositories como Single Source of Truth
Toda busca de dados deve passar pelo Repository, que decide de onde vem o dado (API, cache, local storage).

### 8.4 Use códigos de erro para tradução
```dart
// ✅ BOM
throw AppException("invalidCredentials");

// ❌ RUIM
throw AppException("Credenciais inválidas"); // Texto hardcoded
```

### 8.5 DTOs devem ser reativos e validados
Use DTOs que estendem ChangeNotifier e validadores LucidValidation para UI reativa e validação robusta.

```dart
// ✅ BOM
class CreateBoxDto extends ChangeNotifier {
  String label;
  
  set setLabel(String value) {
    label = value;
    notifyListeners();
  }
}

class CreateBoxDtoValidator extends LucidValidator<CreateBoxDto> {
  CreateBoxDtoValidator() {
    ruleFor((box) => box.label, key: "label")
      .notEmpty()
      .minLength(3);
  }
}

// ❌ RUIM
class CreateBoxDto {
  String label; // Não é reativo, sem validação
}
```

### 8.6 Modularização por Feature
Organize o código por funcionalidade (feature), não por tipo técnico.

```
// ✅ BOM
modules/
  box/
    ui/
    repositories/
    gateway/
    dto/

// ❌ RUIM
controllers/
  box_controller.dart
  auth_controller.dart
repositories/
  box_repository.dart
  auth_repository.dart
```

---

## 9. Resumo

| Camada | Responsabilidade | Componentes |
|--------|------------------|-------------|
| **UI Layer** | Apresentação e interação | Page, ViewModel/Controller, Command, DTO |
| **Logic Layer** | Lógica de negócio | Use Cases (quando necessário) |
| **Data Layer** | Acesso e gerenciamento de dados | Repository, Gateway, Services |
| **Core** | Funcionalidades compartilhadas | LocalStorage, ImagePicker, GeoLocator, etc. |

### Fluxo típico:
1. **Page** escuta mudanças no **Command**
2. **Controller** invoca **Command.execute()**
3. **Command** chama **Repository** (ou Use Case)
4. **Repository** consulta **Gateway** (API) ou **Services** (LocalStorage, GPS, etc.)
5. **Repository** retorna `Either<Exception, Data>`
6. **Command** atualiza seu **CommandState**
7. **Page** reage ao novo estado (mostra loader, erro, sucesso)

---

## 10. Referências

- [Google App Architecture Guide](https://developer.android.com/topic/architecture)
- [Flutter Modular](https://pub.dev/packages/flutter_modular)
- [LucidValidation](https://pub.dev/packages/lucid_validation)
- [Either Pattern (Functional Programming)](https://en.wikipedia.org/wiki/Monad_(functional_programming))

---

**Última atualização:** 24 de Outubro de 2025

