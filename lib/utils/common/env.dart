// const ENV env = ENV.uat;

// enum ENV { development, qa, uat }

// extension ConfigExt on ENV {
//   String get baseurl {
//     switch (this) {
//       case ENV.qa:
//         return 'YOUR_PROJECT_QA_URL';
//       case ENV.development:
//         return 'YOUR_PROJECT_DEVELOPMENT_URL';
//       case ENV.uat:
//         return 'YOUR_PROJECT_UAT_URL';
//     }
//     return '';
//   }
// }

enum Environment {
  dev,
  staging,
  production,
}

class EnvironmentService {
  EnvironmentService(this.environment) : assert(environment != null);
  Environment environment;

  T getValue<T>({T? dev, T? staging, T? prod}) {
    switch (environment) {
      case Environment.dev:
        return dev!;
      case Environment.staging:
        return staging!;
      case Environment.production:
        return prod!;
      default:
        throw Exception('Invalid environment name provided');
    }
  }

  
}
