const pajakFailModal = document.querySelector('[data-pajak-fail-modal]');
const pajakFailIdInput = document.querySelector('[data-pajak-fail-id]');

if (pajakFailModal && pajakFailIdInput) {
    const closePajakFailModal = () => {
        pajakFailModal.setAttribute('hidden', '');
        pajakFailIdInput.value = '';
    };

    document.addEventListener('click', (event) => {
        const failButton = event.target.closest('.js-fail-pajak');
        const cancelButton = event.target.closest('[data-pajak-fail-cancel]');

        if (failButton) {
            pajakFailIdInput.value = failButton.dataset.transactionId || '';
            pajakFailModal.removeAttribute('hidden');
            return;
        }

        if (cancelButton) {
            closePajakFailModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && !pajakFailModal.hidden) {
            closePajakFailModal();
        }
    });
}
