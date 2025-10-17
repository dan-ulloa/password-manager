
## 🧩 1. **Manejo de formularios y validaciones**

### 🔹 Clases y widgets principales:

* [`Form`](https://api.flutter.dev/flutter/widgets/Form-class.html)
  → Contenedor para agrupar y gestionar varios campos de formulario.
* [`GlobalKey<FormState>`](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html)
  → Permite acceder al estado del formulario para validaciones globales.
* [`TextFormField`](https://api.flutter.dev/flutter/material/TextFormField-class.html)
  → Campo de texto con validación integrada (`validator`, `onChanged`, `autovalidateMode`).
* [`FormField`](https://api.flutter.dev/flutter/widgets/FormField-class.html)
  → Clase base si quieres crear campos personalizados con lógica de validación propia.

📘 **Consulta oficial:**

> [Flutter docs – Build and validate forms](https://docs.flutter.dev/cookbook/forms/validation)

---

## ⚙️ 2. **Validación en tiempo real**

### 🔹 Conceptos clave:

* `onChanged:` → callback que se llama cada vez que el usuario escribe.
* `setState()` o `ValueNotifier` → para actualizar el estado visual de los criterios.
* `autovalidateMode:` → para validar automáticamente conforme se edita.

📘 **Consulta oficial:**

> [AutovalidateMode enum](https://api.flutter.dev/flutter/widgets/AutovalidateMode.html)

---

## 🔒 3. **Evaluar la seguridad de la contraseña**

### 🔹 Clases / conceptos de Dart:

* [`RegExp`](https://api.flutter.dev/flutter/dart-core/RegExp-class.html)
  → Para comprobar longitud mínima, mayúsculas, símbolos, etc.
* [`TextEditingController`](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)
  → Para leer el texto del campo en tiempo real y analizarlo.

📘 **Consulta oficial:**

> [RegExp in Dart Language Tour](https://dart.dev/guides/language/language-tour#regular-expressions)

---

## 🎨 4. **Retroalimentación visual (feedback de seguridad)**

### 🔹 Widgets recomendados:

* [`LinearProgressIndicator`](https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html)
  → Para mostrar el nivel de fortaleza visualmente.
* [`AnimatedContainer`](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)
  → Para transiciones suaves de color o tamaño según el nivel de seguridad.
* [`Row` / `Column` / `ListTile`]
  → Para listar los criterios cumplidos o no (mayúscula, número, longitud, símbolo...).

📘 **Consulta oficial:**

> [Flutter animations overview](https://docs.flutter.dev/ui/animations/overview)

---

## 🧠 5. **Gestión del estado para actualizaciones en tiempo real**

### 🔹 Opciones recomendadas:

* `StatefulWidget` + `setState()` → Suficiente para validación local.
* [`ValueNotifier` y `ValueListenableBuilder`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) → Para un enfoque más reactivo sin `setState`.
* [`ChangeNotifier` y `Provider`](https://pub.dev/packages/provider) → Si la validación influye en otras partes (por ejemplo, activar/desactivar un botón global).

📘 **Consulta oficial:**

> [Flutter docs – Manage state](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

---

## 💡 6. **Accesibilidad y UX**

* [`FocusNode`](https://api.flutter.dev/flutter/widgets/FocusNode-class.html) → Para manejar el foco entre campos.
* [`TextInputAction`](https://api.flutter.dev/flutter/services/TextInputAction.html) → Para controlar el botón del teclado (“next”, “done”).
* [`ObscureText`](https://api.flutter.dev/flutter/material/TextFormField/obscureText.html) → Para ocultar/mostrar la contraseña.

---

### 🧾 En resumen — consulta estos elementos en la documentación oficial:

| Categoría                 | Clases / Widgets / Conceptos                                           | Documentación                                                                           |
| ------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Formulario                | `Form`, `TextFormField`, `FormField`, `GlobalKey<FormState>`           | [Build and validate forms](https://docs.flutter.dev/cookbook/forms/validation)          |
| Validación en tiempo real | `onChanged`, `autovalidateMode`, `RegExp`                              | [Dart RegExp](https://dart.dev/guides/language/language-tour#regular-expressions)       |
| Estado reactivo           | `ValueNotifier`, `ChangeNotifier`, `Provider`                          | [State management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)         |
| Feedback visual           | `AnimatedContainer`, `LinearProgressIndicator`, `Colors`               | [Animations overview](https://docs.flutter.dev/ui/animations/overview)                  |
| Control de texto          | `TextEditingController`, `FocusNode`, `TextInputAction`, `obscureText` | [API Reference – widgets](https://api.flutter.dev/flutter/widgets/widgets-library.html) |

---