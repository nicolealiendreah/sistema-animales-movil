const bool isEmulator = true; // Poner false si se usa celular real
const String localIP = '192.168.1.11'; // IP en la red local
const String deployedUrl = 'https://la-api-en-la-nube.com'; // URL API desplegada

// const String apiUrl = deployedUrl;
const String apiUrl = isEmulator
    ? 'http://10.0.2.2:5000'       // Emulador Android (localhost)
    : 'http://$localIP:5000';      // Dispositivo físico en red local

const String baseImageUrl = '$apiUrl/uploads';
const String baseUrl = '$apiUrl/api';
