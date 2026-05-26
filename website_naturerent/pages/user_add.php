<?php
require_once __DIR__ . '/../config/supabase.php';

$formErrors = [];
$formValues = [
    'nama' => '',
    'email' => '',
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $formValues['nama'] = trim($_POST['nama'] ?? '');
    $formValues['email'] = trim($_POST['email'] ?? '');
    $password = (string) ($_POST['password'] ?? '');
    $passwordConfirmation = (string) ($_POST['password_confirmation'] ?? '');

    if ($formValues['nama'] === '') {
        $formErrors[] = 'Nama lengkap wajib diisi.';
    }

    if (!filter_var($formValues['email'], FILTER_VALIDATE_EMAIL)) {
        $formErrors[] = 'Email tidak valid.';
    }

    if ($password === '') {
        $formErrors[] = 'Password wajib diisi.';
    }

    if ($password !== $passwordConfirmation) {
        $formErrors[] = 'Konfirmasi password tidak sama.';
    }

    if (empty($formErrors)) {
        $result = createRegularUser($formValues['nama'], $formValues['email'], $password);

        if ($result['ok']) {
            header('Location: index.php?page=users');
            exit;
        }

        $formErrors[] = 'User gagal disimpan. Periksa koneksi atau izin database.';
    }
}

function formIcon(string $name): string
{
    $icons = [
        'user' => '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle>',
        'mail' => '<rect x="3" y="5" width="18" height="14" rx="2"></rect><path d="m3 7 9 6 9-6"></path>',
        'lock' => '<rect x="5" y="11" width="14" height="10" rx="2"></rect><path d="M8 11V7a4 4 0 0 1 8 0v4"></path>',
        'eye' => '<path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6Z"></path><circle cx="12" cy="12" r="3"></circle>',
        'chevron' => '<path d="m9 18 6-6-6-6"></path>',
        'profile' => '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle>',
    ];

    return '<svg viewBox="0 0 24 24" aria-hidden="true">' . ($icons[$name] ?? '') . '</svg>';
}
?>
<section class="content-card add-user-card">
    <form class="add-user-form" method="POST" action="index.php?page=users&action=add">
        <div class="add-user-body">
            <div class="form-intro">
                <div class="form-intro-icon">
                    <?= formIcon('profile') ?>
                </div>
                <div>
                    <h2>Informasi Pengguna</h2>
                    <p>Lengkapi informasi berikut untuk melanjutkan</p>
                </div>
            </div>

            <?php if (!empty($formErrors)): ?>
                <div class="form-alert">
                    <?= htmlspecialchars($formErrors[0]) ?>
                </div>
            <?php endif; ?>

            <div class="add-user-grid">
                <label class="form-field">
                    <span>Nama Lengkap</span>
                    <div class="input-shell">
                        <?= formIcon('user') ?>
                        <input
                            type="text"
                            name="nama"
                            value="<?= htmlspecialchars($formValues['nama']) ?>"
                            placeholder="Masukkan nama lengkap"
                            required
                        >
                    </div>
                </label>

                <label class="form-field">
                    <span>Email</span>
                    <div class="input-shell">
                        <?= formIcon('mail') ?>
                        <input
                            type="email"
                            name="email"
                            value="<?= htmlspecialchars($formValues['email']) ?>"
                            placeholder="Masukkan email"
                            required
                        >
                    </div>
                </label>

                <label class="form-field">
                    <span>Password</span>
                    <div class="input-shell">
                        <?= formIcon('lock') ?>
                        <input
                            type="password"
                            name="password"
                            placeholder="Masukkan password"
                            required
                        >
                        <button class="password-eye" type="button" aria-label="Tampilkan password">
                            <?= formIcon('eye') ?>
                        </button>
                    </div>
                </label>

                <label class="form-field">
                    <span>Konfirmasi Password</span>
                    <div class="input-shell">
                        <?= formIcon('lock') ?>
                        <input
                            type="password"
                            name="password_confirmation"
                            placeholder="Masukkan password"
                            required
                        >
                        <button class="password-eye" type="button" aria-label="Tampilkan password">
                            <?= formIcon('eye') ?>
                        </button>
                    </div>
                </label>
            </div>
        </div>

        <div class="add-user-actions">
            <a class="secondary-button" href="index.php?page=users">Batal</a>
            <button class="primary-button save-user-button" type="submit">
                Simpan User
                <?= formIcon('chevron') ?>
            </button>
        </div>
    </form>
</section>
