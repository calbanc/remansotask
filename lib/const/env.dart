import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
  static final String basePrueba =
      dotenv.env['BASE_PRUEBA'] ?? 'http://localhost:3000';

  static final int dbversion =
      int.parse(dotenv.env['DBVERSION']!);
  static final String versionapp =
  dotenv.env['VERSIONAPP']??'';


  static final String msalClientId =
      dotenv.env['MSAL_CLIENT_ID'] ?? '00000000-0000-0000-0000-000000000000';
  static final String msalAuthority = dotenv.env['MSAL_AUTHORITY'] ??
      'https://login.microsoftonline.com/organizations';
  static final String msalRedirectUri = dotenv.env['MSAL_REDIRECT_URI'] ??
      'msauth://com.azuresamples.msalflutter';
  static final String msalTenantId =
      dotenv.env['MSAL_TENANT_ID'] ?? '00000000-0000-0000-0000-000000000000';
  static final String keyencry = dotenv.env['KEY'] ?? "V3RFrU72O2RLA30R";
}
