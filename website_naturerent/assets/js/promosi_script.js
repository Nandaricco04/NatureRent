const promosiDeleteModal = document.querySelector('[data-promosi-delete-modal]');
const promosiDeleteIdInput = document.querySelector('[data-promosi-delete-id]');

if (promosiDeleteModal && promosiDeleteIdInput) {
    const closePromosiDeleteModal = () => {
        promosiDeleteModal.setAttribute('hidden', '');
        promosiDeleteIdInput.value = '';
    };

    document.addEventListener('click', (event) => {
        const deleteButton = event.target.closest('.js-delete-promosi');
        const cancelButton = event.target.closest('[data-promosi-delete-cancel]');

        if (deleteButton) {
            event.preventDefault();
            promosiDeleteIdInput.value = deleteButton.dataset.promosiId || '';
            promosiDeleteModal.removeAttribute('hidden');
            return;
        }

        if (cancelButton) {
            closePromosiDeleteModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && !promosiDeleteModal.hidden) {
            closePromosiDeleteModal();
        }
    });
}
