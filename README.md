# TerminBA

**TerminBA** is a comprehensive software solution developed to facilitate the reservation and management of sport centers. The platform enhances communication and operations between sport center managers, clients, and administrators by providing seamless interaction across all parties. The system is built with an **ASP.NET Core Web API** backend and a **Flutter** frontend.

## Features

- **Desktop Applications**: Tailored for sport center managers and system administrators, offering essential tools to manage their services, reservations, and center details effectively.
- **Mobile Application**: Designed for clients, enabling convenient browsing of sport centers and booking of appointments (termini).
- **Integrated Platform**: The system unifies all three user groups, streamlining communication, service requests, and payments.

## Technologies Used

- **Backend**: ASP.NET Core Web API with Entity Framework. The API, SQL database, and message brokers are containerized using Docker.
- **Frontend**: Flutter (for both desktop and mobile applications).
- **Messaging**: RabbitMQ for asynchronous communication.

## Getting Started

Follow the steps below to set up and run the project.

### Prerequisites

Ensure you have the following tools installed:
- **Docker**: For containerizing the backend, database, and RabbitMQ.
- **Visual Studio Code / Android Studio**: Recommended for editing and running the frontend (Flutter).
- **Flutter SDK**: To run the desktop and mobile applications.

### Clone the Repository

```bash
git clone https://github.com/your-username/TerminBA.git
```
*(Replace `your-username` with your actual GitHub username)*

### Environment variables

The following environment variables are required. You can define these variables by creating a `.env` file in the root folder (`TerminBA/TerminBA`). 

### Running the Backend API

To start the API, database, and other services, navigate to the project's root folder (`TerminBA/TerminBA`) and run the following command:
```
docker-compose up --build
```
Wait for Docker to finish composing. This might take a few minutes. 

### Running the Desktop Apps

The desktop applications are designed for the sport center managers and system administrator roles. To run them:

1. Navigate to the appropriate folder based on role:
- `TerminBA.UI/terminba_sport_center_desktop` for sport center managers.
- `TerminBA.UI/terminba_admin_desktop` for the system administrator.

2. Install the necessary dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d windows
```

### Running the Mobile App

1. Navigate to the mobile app folder: `TerminBA.UI/terminba_mobile`.

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```
*(Note: You might need an Android Virtual Device running or a physical device connected).*

### Credentials For Testing

#### Administrator App
- Username: `admin`
- Password: `password`

#### Sport Center App
- Username: `skenderija`
- Password: `password`

#### User App
- Username: `user`
- Password: `password`

*Note: Other users that are seeded in the database generally also use the password `password` for testing.*
*Note: Only "user" has a valid email address (mine for university).*


#### Testing Payments

To test payment processing, use the following details:

- Card Number: ```4242 4242 4242 4242```
- Expiration Date: ```Any future date```
- CVC: ```Any three-digit number```

## License

This project is licensed under the [MIT License](LICENSE).
