/* ============================================================
   owner_verif_script.js — Verifikasi Owner
   ============================================================ */

document.addEventListener('DOMContentLoaded', function () {
    // Auto hide alert setelah 3 detik
    const alerts = document.querySelectorAll('.verif-alert');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity    = '0';
            setTimeout(function () {
                alert.remove();
            }, 500);
        }, 3000);
    });
});