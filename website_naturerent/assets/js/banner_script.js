const destinationModal = document.querySelector('[data-destination-modal]');
const destinationFileInput = document.querySelector('[data-destination-file]');
const destinationPreview = document.querySelector('[data-destination-preview]');
const destinationPreviewImage = destinationPreview?.querySelector('img');
const destinationFileName = document.querySelector('[data-destination-file-name]');

if (destinationModal) {
    const closeDestinationModal = () => {
        if (destinationModal.dataset.returnUrl) {
            window.location.href = destinationModal.dataset.returnUrl;
            return;
        }

        destinationModal.setAttribute('hidden', '');
    };

    document.addEventListener('click', (event) => {
        const closeButton = event.target.closest('[data-close-destination-modal]');

        if (closeButton) {
            closeDestinationModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && !destinationModal.hidden) {
            closeDestinationModal();
        }
    });
}

if (destinationFileInput && destinationPreview && destinationPreviewImage && destinationFileName) {
    destinationFileInput.addEventListener('change', () => {
        const file = destinationFileInput.files?.[0];

        if (!file) {
            destinationPreview.setAttribute('hidden', '');
            destinationPreviewImage.src = '';
            destinationFileName.textContent = '';
            return;
        }

        if (file.size > 3 * 1024 * 1024) {
            alert('Ukuran gambar maksimal 3 MB.');
            destinationFileInput.value = '';
            destinationPreview.setAttribute('hidden', '');
            destinationPreviewImage.src = '';
            destinationFileName.textContent = '';
            return;
        }

        destinationPreviewImage.src = URL.createObjectURL(file);
        destinationFileName.textContent = file.name;
        destinationPreview.removeAttribute('hidden');
    });
}

const locationTrigger = document.querySelector('[data-location-trigger]');
const locationMenu = document.querySelector('[data-location-menu]');
const locationInput = document.querySelector('[data-location-value]');
const locationLabel = document.querySelector('[data-location-label]');

if (locationTrigger && locationMenu && locationInput && locationLabel) {
    locationTrigger.addEventListener('click', () => {
        if (locationMenu.hidden) {
            locationMenu.removeAttribute('hidden');
        } else {
            locationMenu.setAttribute('hidden', '');
        }
    });

    document.addEventListener('click', (event) => {
        const option = event.target.closest('[data-location-option]');
        const insideLocationPicker = event.target.closest('.destination-input-shell');

        if (option) {
            locationInput.value = option.dataset.locationId || '';
            locationLabel.textContent = option.dataset.locationName || 'Pilih Lokasi';

            document.querySelectorAll('[data-location-option]').forEach((item) => {
                item.classList.toggle('is-selected', item === option);
            });

            locationMenu.setAttribute('hidden', '');
            return;
        }

        if (!insideLocationPicker) {
            locationMenu.setAttribute('hidden', '');
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            locationMenu.setAttribute('hidden', '');
        }
    });
}

const deleteBannerModal = document.querySelector('[data-delete-banner-modal]');
const deleteBannerIdInput = document.querySelector('[data-delete-banner-id]');

if (deleteBannerModal && deleteBannerIdInput) {
    const closeDeleteBannerModal = () => {
        deleteBannerModal.setAttribute('hidden', '');
        deleteBannerIdInput.value = '';
    };

    document.addEventListener('click', (event) => {
        const deleteButton = event.target.closest('[data-delete-banner]');
        const cancelButton = event.target.closest('[data-delete-banner-cancel]');

        if (deleteButton) {
            deleteBannerIdInput.value = deleteButton.dataset.bannerId || '';
            deleteBannerModal.removeAttribute('hidden');
            return;
        }

        if (cancelButton) {
            closeDeleteBannerModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && !deleteBannerModal.hidden) {
            closeDeleteBannerModal();
        }
    });
}
