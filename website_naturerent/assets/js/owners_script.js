/* ============================================================
   owners_script.js — Owner Management
   ============================================================ */

function ownerShowModal(ownerId, action) {
    document.getElementById('ownerModalId').value     = ownerId;
    document.getElementById('ownerModalAction').value = action;

    const icon    = document.getElementById('ownerModalIcon');
    const title   = document.getElementById('ownerModalTitle');
    const desc    = document.getElementById('ownerModalDesc');
    const konfirm = document.getElementById('ownerModalKonfirm');

    if (action === 'deactivate') {
        icon.innerHTML        = '<iconify-icon icon="tabler:user-off"></iconify-icon>';
        icon.style.background = '#F1EFE8';
        icon.style.color      = '#5F5E5A';
        title.textContent     = 'Nonaktifkan akun ini?';
        desc.textContent      = 'Anda yakin ingin menonaktifkan akun ini?';
        konfirm.textContent   = 'Ya, Nonaktifkan';
        konfirm.className     = 'owner-btn-konfirm nonaktif';
    } else {
        icon.innerHTML        = '<iconify-icon icon="tabler:user-check"></iconify-icon>';
        icon.style.background = '#E1F5EE';
        icon.style.color      = '#0F6E56';
        title.textContent     = 'Aktifkan akun ini?';
        desc.textContent      = 'Anda yakin ingin mengaktifkan kembali akun ini?';
        konfirm.textContent   = 'Ya, Aktifkan';
        konfirm.className     = 'owner-btn-konfirm';
    }

    document.getElementById('ownerModalOverlay').classList.add('show');
}

function ownerCloseModal() {
    document.getElementById('ownerModalOverlay').classList.remove('show');
}

// Tutup modal saat klik di luar
document.addEventListener('DOMContentLoaded', function () {
    const overlay = document.getElementById('ownerModalOverlay');
    if (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === this) ownerCloseModal();
        });
    }
});