<?php
session_start();

require_once __DIR__ . '/config/supabase.php';

if (!empty($_SESSION['admin'])) {
    header('Location: index.php');
    exit;
}

$error = '';
$email = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = strtolower(trim($_POST['email'] ?? ''));
    $password = trim($_POST['password'] ?? '');

    if ($email === '' || $password === '') {
        $error = 'Email dan password wajib diisi.';
    } else {
        $user = findUserByEmail($email);

        if (!$user) {
            $error = 'Email tidak terdaftar.';
        } elseif (!password_verify($password, $user['password'] ?? '')) {
            $error = 'Password salah.';
        } else {
            $role = strtolower(trim($user['role'] ?? ''));

            if (!in_array($role, ['admin', 'administrator'], true)) {
                $error = 'Akun ini bukan akun admin.';
            } else {
                $_SESSION['admin'] = [
                    'id' => $user['id_user'] ?? null,
                    'name' => $user['nama'] ?? 'Admin',
                    'email' => $user['email'] ?? $email,
                    'role' => $role,
                ];

                header('Location: index.php');
                exit;
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Admin - NatureRent</title>
    <link rel="stylesheet" href="assets/css/login.css">
</head>
<body>
    <main class="login-page">
        <section class="login-card" aria-label="Form login admin">
            <div class="brand-badge">
                <img src="assets/img/Logo.png" alt="NatureRent">
            </div>

            <h1>Selamat Datang!</h1>
            <p>Masuk untuk Mengelola Sistem</p>

            <?php if ($error !== ''): ?>
                <div class="alert"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>

            <form method="POST" autocomplete="off">
                <label for="email">Email</label>
                <div class="input-wrap">
                    <span class="input-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                        </svg>
                    </span>
                    <input
                        id="email"
                        type="email"
                        name="email"
                        value="<?= htmlspecialchars($email) ?>"
                        placeholder="email@gmail.com"
                        required
                    >
                </div>

                <label for="password">Password</label>
                <div class="input-wrap">
                    <span class="input-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <rect width="18" height="11" x="3" y="11" rx="2" ry="2"></rect>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                        </svg>
                    </span>
                    <input
                        id="password"
                        type="password"
                        name="password"
                        placeholder="Masukkan password"
                        required
                    >
                    <button class="toggle-password" type="button" aria-label="Tampilkan password">
                        <svg viewBox="0 0 24 24">
                            <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>

                <button class="login-button" type="submit">Login</button>
            </form>
        </section>
    </main>

    <script src="assets/js/script.js"></script>
</body>
</html>
