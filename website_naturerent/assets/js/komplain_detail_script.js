document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.kd-alert').forEach(function (el) {
        setTimeout(function () {
            el.style.transition = 'opacity 0.5s';
            el.style.opacity    = '0';
            setTimeout(function () { el.remove(); }, 500);
        }, 3000);
    });
});