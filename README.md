# iOS Project Template

## Overview

This native iOS project template, written in **Swift 6**, is designed with the MVVM architecture in mind, providing a robust starting point for building high-quality iOS applications. The template comes packed with useful features, including:

- **MVVM Architecture:** Separates business logic from the UI, making your code more maintainable and testable.
- **Networking Framework:** Built on Alamofire with a custom request interceptor and retry mechanism for token refreshing.
- **Storyboard Framework for Team Collaboration:** Optimized to reduce merge conflicts, perfect for multi-developer teams.
- **BLE Manager:** Integrated module for managing Bluetooth Low Energy (BLE) functionalities.
- **Internationalization:** Out-of-the-box support for multiple languages to simplify app localization.

## Features

- **MVVM Architecture**
  - Clear separation of Model, View, and ViewModel layers to enhance modularity and facilitate unit testing.
  
- **Networking Framework**
  - Leverages Alamofire to manage HTTP requests and responses.
  - Includes a built-in request interceptor (`APIRequestInterceptor`) and network service layer (`APIService`) that automatically handle authorization, token refresh, and error retry logic.

- **Storyboard Framework for Team Collaboration**
  - Designed to minimize merge conflicts and streamline collaboration among multiple developers.

- **BLE Manager**
  - Provides a dedicated module to simplify the integration and management of BLE functionalities.

- **Internationalization**
  - Preconfigured with resources to support multiple languages, making localization straightforward.

## License

This project is open source under the MIT License. See the LICENSE file for more details.
