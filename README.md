# Drivana Test

## Enlaces Importantes
- **Video de demostración**: [https://drive.google.com/file/d/1SBTlMLXboYDH563-05XQbXAt5eHhOdjF/view?usp=sharing](https://drive.google.com/file/d/1SBTlMLXboYDH563-05XQbXAt5eHhOdjF/view?usp=sharing)
- **Aplicación en vivo**: [https://drivana.getyato.com](https://drivana.getyato.com)
- **Documentación API**: [https://www.postman.com/whiteborad/drivana/documentation/mbwqmux/drivana-test](https://www.postman.com/whiteborad/drivana/documentation/mbwqmux/drivana-test)

## Descripción
Proyecto desarrollado con Ruby on Rails 8 y PostgreSQL para gestionar un sistema de reservas de vehículos, incluyendo funcionalidades para la creación de reservas, extensiones y generación de tickets.

## Tecnologías Principales
- Ruby on Rails 8
- PostgreSQL como base de datos principal
- Docker para containerización
- Kamal para despliegue en Digital Ocean o cualquier otro proveedor de cloud

## Gemas y Dependencias
### Base de Datos y ORM
- `pg`: Adaptador PostgreSQL para ActiveRecord
- `sqlite3`: *(No implementado)* Inicialmente considerado para la creación de colas para la generación de tickets en PDF

### Autenticación y Autorización
- `devise`: Sistema de autenticación
- `devise-jwt`: Autenticación mediante tokens JWT
- `pundit`: Sistema de autorización y políticas de acceso

### Testing
- `rspec-rails`: Framework principal de testing
- `factory_bot_rails`: Creación de datos de prueba
- `shoulda-matchers`: Matchers adicionales para pruebas
- `pundit-matchers`: Matchers específicos para pruebas de políticas
- `simplecov`: Análisis de cobertura de pruebas (99% alcanzado)

### Frontend y UI
- `tailwindcss-rails`: Framework CSS para estilos
- `jsonapi-serializer`: Serialización de JSON API

### Utilidades
- `money-rails`: Manejo escalable de precios y monedas

## Modelos del Sistema
- **User**: 
  - Gestión de usuarios con roles de `customer` (cliente) y `hoster` (anfitrión)
  - Customers pueden rentar autos
  - Hosters pueden ofrecer sus vehículos para renta

- **Booking**: Gestión de reservas de vehículos

- **BookingExtension**: Extensiones de reservas existentes

- **Car**: Gestión de vehículos disponibles

- **Ticket**: 
  - Sistema polimórfico para tickets
  - Asociado a Bookings y BookingExtensions
  - Diseñado para ser escalable a futuros servicios

- **JWTDenyList**: Lista negra de tokens JWT para seguridad

## Endpoints API

### Reservas (Bookings)
- `POST /bookings` - Crear una reserva
- `POST /bookings/:id/extend` - Extender una reserva existente
- `GET /bookings/:id` - Obtener detalles de una reserva

### Tickets
- `POST /tickets` - Generar ticket para reserva o extensión
- `GET /tickets/:id` - Obtener ticket individual
- `GET /bookings/:id/tickets` - Obtener todos los tickets de una reserva
- `GET /bookings/:id/consolidated_ticket` - Obtener ticket consolidado

## Testing
- Cobertura del 99% en pruebas
- Incluye pruebas para:
  - Modelos
  - Controladores
  - Helpers
  - Políticas
- Se excluyen métodos específicos de Rails

## Interfaz de Usuario
Se incluye una interfaz de usuario básica que permite realizar todas las operaciones necesarias del sistema. Es importante mencionar que el frontend es minimalista y no está diseñado para ser responsive, ya que el enfoque principal del proyecto está en la funcionalidad del backend y la API.

## Características Adicionales
- Sistema de roles para usuarios (customer/hoster)
- Manejo de monedas escalable (actualmente MXN)
- Sistema de tickets polimórfico y extensible
- Autenticación JWT con lista negra de tokens
- Políticas de autorización granulares

## Instalación y Configuración
[Pendiente de agregar instrucciones específicas]

## Despliegue
El proyecto está configurado para ser desplegado en Digital Ocean o cualquier otro proveedor de cloud utilizando Docker y Kamal. La combinación de estas tecnologías nos permite realizar despliegues con zero downtime, asegurando que la aplicación esté siempre disponible durante las actualizaciones.

## Pruebas
Para ejecutar las pruebas:
```bash
bundle exec rspec
```

Para ver el reporte de cobertura, abrir `coverage/index.html` después de ejecutar las pruebas.
