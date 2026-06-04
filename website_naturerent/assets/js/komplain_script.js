// Auto submit search saat ketik
let _kmSearchTimer;
const kmSearch = document.getElementById('komplainKeyword');
if (kmSearch) {
    kmSearch.addEventListener('input', function () {
        clearTimeout(_kmSearchTimer);
        _kmSearchTimer = setTimeout(function () {
            document.getElementById('komplainFilterForm').submit();
        }, 500);
    });
}

// Submit filter saat dropdown berubah
const kmFilter = document.getElementById('komplainStatusFilter');
if (kmFilter) {
    kmFilter.addEventListener('change', function () {
        document.getElementById('hiddenStatus').value = this.value !== 'Semua' ? this.value : '';
        document.getElementById('komplainFilterForm').submit();
    });
}

// Modal hapus
function komplainOpenHapus(id) {
    document.getElementById('km-hapus-id').value = id;
    document.getElementById('komplainModalHapus').classList.add('open');
}

function komplainCloseModal(id) {
    document.getElementById(id).classList.remove('open');
}

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.komplain-modal-overlay').forEach(function (el) {
        el.addEventListener('click', function (e) {
            if (e.target === this) komplainCloseModal(this.id);
        });
    });
});