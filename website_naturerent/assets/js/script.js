const toggleButton = document.querySelector('.toggle-password');
const passwordInput = document.querySelector('#password');

if (toggleButton && passwordInput) {
    toggleButton.addEventListener('click', () => {
        const isPassword = passwordInput.type === 'password';
        passwordInput.type = isPassword ? 'text' : 'password';
        toggleButton.setAttribute(
            'aria-label',
            isPassword ? 'Sembunyikan password' : 'Tampilkan password'
        );
    });
}

document.querySelectorAll('.password-eye').forEach((button) => {
    button.addEventListener('click', () => {
        const input = button.closest('.input-shell')?.querySelector('input');

        if (!input) {
            return;
        }

        const isPassword = input.type === 'password';
        input.type = isPassword ? 'text' : 'password';
        button.setAttribute(
            'aria-label',
            isPassword ? 'Sembunyikan password' : 'Tampilkan password'
        );
    });
});

const deleteModal = document.querySelector('[data-delete-modal]');
const deleteUserIdInput = document.querySelector('[data-delete-user-id]');

if (deleteModal && deleteUserIdInput) {
    const closeDeleteModal = () => {
        deleteModal.setAttribute('hidden', '');
        deleteUserIdInput.value = '';
    };

    document.addEventListener('click', (event) => {
        const deleteButton = event.target.closest('.js-delete-user');
        const cancelButton = event.target.closest('[data-delete-cancel]');

        if (deleteButton) {
            event.preventDefault();
            deleteUserIdInput.value = deleteButton.dataset.userId || '';
            deleteModal.removeAttribute('hidden');
            return;
        }

        if (cancelButton) {
            closeDeleteModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && !deleteModal.hidden) {
            closeDeleteModal();
        }
    });
}
