# scanlytics

## Run Backend

From the repository root:

```powershell
cd backend
C:/Users/Kishan/AppData/Local/Programs/Python/Python314/python.exe app.py
```

The backend listens on all interfaces at port 5000.

Quick checks:

- `http://127.0.0.1:5000/`
- `http://127.0.0.1:5000/health`

## Run Flutter On Phone

Make sure phone and laptop are on the same Wi-Fi.

Find laptop IP (Windows):

```powershell
ipconfig
```

Use the active Wi-Fi IPv4 address.

From `scanlytics`:

```powershell
flutter run --dart-define=API_HOST=<your-laptop-ip>
```

Example:

```powershell
flutter run --dart-define=API_HOST=10.239.70.55
```

Alternative:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.239.70.55:5000
```

## Notes

- Android manifest already allows cleartext HTTP traffic for local testing.
- Physical phones must set `API_HOST`; emulator defaults are different.
- If phone still cannot connect, allow Python/port 5000 in Windows Firewall.
- Verify backend contract on laptop browser: `http://<laptop-ip>:5000/health` should return JSON with `status: ok`.
