
---

## Resumen rápido (respuesta directa)

* **Sí necesitas un lugar accesible *antes* de abrir la BD** para leer el `salt` y validar el verificador.
* **La mejor práctica práctica y práctica común**: mantener el `salt` y el verificador (hash) **en un almacenamiento accesible** para inicio (p. ej. Keychain/Keystore via `flutter_secure_storage` o en un archivo/metadata no cifrado).
* **Para permitir backups portables**, también **incluir el mismo `salt` y verificador dentro del archivo de exportación** (la exportación debe estar cifrada y/o firmada).
* **No guardar la masterKey en claro**; si guardas algo para biometría, guarda la masterKey *envuelta* (wrapped) por el Keystore y bajo protección biométrica.
* En resumen: **salt para apertura = accesible**, **salt para export = incluido en backup cifrado**. Luego, aplicar políticas de coherencia (wipe de claves huérfanas, verificación a inicio).

---

## Por qué el `salt` debe estar accesible antes de abrir la BD

* Para derivar la masterKey con Argon2id necesitas `password + salt`.
* Si guardas el `salt` **dentro** de la BD cifrada → no puedes leerlo sin la clave → ciclo imposible.
* Por eso **el `salt` debe existir en un lugar accesible** al arrancar la app (device storage o secure storage).

> Nota: *el salt NO es secreto.* Su exposición no debilita la seguridad salvo que la contraseña sea mala. Lo que protege es la derivación (Argon2id) y la contraseña.

---

## Estrategia robusta recomendada (pasos concretos)

### 1) En el registro (first-time signup)

1. Generas `salt` (CSPRNG, 16–32 bytes).
2. Derivas `masterKey = Argon2id(password, salt)`.
3. Calculas `verifier = SHA256(masterKey)` (o HKDF(masterKey,"VERIFIER")).
4. **Guardas el salt y el verifier en `flutter_secure_storage`** (Keychain/Keystore).
5. **Inicializas la DB cifrada** usando la subkey para DB: `dbKey = HKDF(masterKey, "DB_ENCRYPTION")` y abres la DB.
6. **Opcional:** dentro de la BD guardas la misma metadata (`vault_metadata` con salt/verifier) para que viaje con la bóveda cuando exportes. (Ver abajo.)

### 2) En cada login

1. Lees `salt` desde `flutter_secure_storage` (o archivo accesible).
2. Derivas `masterKey = Argon2id(password, salt)`.
3. Calculas `SHA256(masterKey)` y lo comparas con `verifier` guardado (verifier en secure storage o en metadata si la BD fue abierta antes).
4. Si coincide, obtienes `dbKey = HKDF(masterKey,"DB_ENCRYPTION")` y abres la BD.

### 3) Para exportar la bóveda (backup portable)

* Exportación **debe** incluir la metadata: `salt`, `kdf_params`, `verifier`, versión del formato.
* El archivo de exportación **debe estar cifrado** con contraseña / passphrase o con masterKey envolvida para evitar exponer la bóveda.
* Así, si pierdes el dispositivo, el usuario puede restaurar a otro dispositivo usando el backup + contraseña maestra (la exportación contiene el salt necesario).

### 4) Si `secure_storage` se pierde (ej. re-instalar app)

* Si el usuario NO tiene backup exportado → **pérdida total** (no hay forma de regenerar salt ni verificar). Debe recrear bóveda.
* Si el usuario TIENE un backup exportado que incluye salt/verifier → puede restaurar y usar su contraseña maestra para derivar masterKey y abrir la BD restaurada.

---

## ¿Entonces debo guardar el salt en **ambos** sitios (secure storage *y* en la BD metadata)?

* **Sí, con condiciones**:

  * Guarda el salt en `flutter_secure_storage` para poder **abrir la BD local** (evitar chicken-egg).
  * **También escribe el mismo salt en `vault_metadata` dentro de la BD** (esto no rompe seguridad porque el salt no es secreto).
  * Para export: incluir esa tabla `vault_metadata` en el archivo exportado.
* **Importante:** Define un único origen de verdad para el flujo normal de apertura (recomiendo `secure_storage`) y usa la copia en la BD **solo para portabilidad/backup**. Mantén lógica para detectar inconsistencias y reconciliar/limpiar (ver más abajo).

---

## Manejo de inconsistencias y política de recuperación

* **Caso A: BD existe pero salt no (secure storage limpio)** → inconsistencia crítica: recomienda *wipe DB y salt*, pedir re-registro (o mostrar mensaje claro).
* **Caso B: Salt existe pero BD no** → borrar salt huérfano y proceder con registro nuevo (o pedir restauración desde backup si el usuario tiene).
* **Caso C: Salt en secure_storage y en vault_metadata coinciden** → OK.
* **Al inicio de app**: comprueba ambos y, si solo existe secure_storage salt, procede a login; si solo existe BD salt, puede considerar que BD es portable (p. ej. restaurada de backup) — pero cuidado: si DB fue copiada y el secure_storage salt es distinto → pide re-registro o restauración segura.

---

## Biometría y masterKey

* **No guardes masterKey en claro.**
* Si quieres desbloqueo biométrico, guarda **masterKey cifrada (wrapped)** en Keychain/Keystore y protege acceso por biometría.
* Ten en cuenta: keychain puede persistir tras desinstalación en iOS (configurable), por eso implementa la detección de claves huérfanas: si DB no existe pero wrapper existe, borra wrapper o solicita re-auth.

---

## Ejemplo de flujo práctico y código (pseudocódigo Dart)

### Guardar salt y verifier en signup

```dart
final salt = secureRandom(16);
final masterKey = await Argon2id().deriveKey(password, salt);
final verifier = sha256.hashBytes(masterKey); // Uint8List

// Guardar en secure storage (para apertura)
await secureStorage.write(key: 'vault_salt', value: base64Encode(salt));
await secureStorage.write(key: 'vault_verifier', value: base64Encode(verifier));

// Abrir DB con dbKey
final dbKey = await HKDF(...).derive(masterKey, context: 'DB_ENCRYPTION');
await dbProvider.initDBWithKey(dbKey);

// Opcional: dentro de BD guardar metadata (para export)
await db.execute("INSERT INTO vault_metadata(k,v) VALUES('salt', ?), ('verifier', ?)", [salt, verifier]);
```

### Login

```dart
final saltB64 = await secureStorage.read(key: 'vault_salt');
final storedVerifierB64 = await secureStorage.read(key: 'vault_verifier');
final salt = base64Decode(saltB64);
final storedVerifier = base64Decode(storedVerifierB64);

final masterKey = await Argon2id().deriveKey(password, salt);
final computedVerifier = sha256.hashBytes(masterKey);

if (!listEquals(computedVerifier, storedVerifier)) {
  // contraseña incorrecta
  return false;
}

final dbKey = await HKDF().derive(masterKey, context: 'DB_ENCRYPTION');
await dbProvider.initDBWithKey(dbKey);
return true;
```

### Export (backup)

* Empaqueta: `vault.db` (o dump), `vault_metadata` (salt, verifier, kdf_params)
* Cifra el archivo export con password / con masterKey envolvida
* Para restaurar: el usuario importa, se extrae salt y verifier, luego pide contraseña maestra para derivar y abrir.

---

## Pros / Contras de las opciones

| Opción                                        | Pros                                                                | Contras                                                                                           |
| --------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Salt en secure_storage + copia en DB metadata | Abre DB al arrancar; backup portable; coherencia para export/import | Necesitas manejo de claves huérfanas; secure_storage puede persistir tras uninstall en iOS        |
| Salt **solo** en DB metadata                  | Todo viaja con DB                                                   | NO puedes abrir DB inicialmente (huevo y gallina)                                                 |
| Salt en archivo no cifrado junto al DB        | Simple y portable                                                   | Salt no es secreto, pero archivo puede perderse o manipularse; menos seguro si quieres integridad |
| Guardar masterKey en secure_storage           | UX cómoda (no pedir password)                                       | Riesgo alto: si se extrae, toda bóveda comprometida                                               |

---

## Recomendaciones finales — checklist práctico

1. **Guardar salt + verifier en `flutter_secure_storage`** para permitir apertura inicial.
2. **Escribir la misma metadata dentro de la BD** una vez abierta (para export/import).
3. **Implementar exportación cifrada** que incluya metadata (salt, kdf_params, verifier).
4. **Soporte de biometría** solo con masterKey *wrapped* y protección hardware (no guardar en claro).
5. **Detectar y limpiar claves huérfanas** al arrancar (si DB falta pero secure storage tiene salt → borrar salt o pedir restauración).
6. **Documentar al usuario**: si no tiene backup y pierde device, no se puede recuperar la bóveda.
7. **Pruebas**: simula reinstalaciones, backups y restores para validar flujos.

---
