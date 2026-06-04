const exportForm = document.querySelector('[data-export-form]');

if (exportForm) {
    const periodOptions = exportForm.querySelector('[data-period-options]');
    const periodValue = exportForm.querySelector('[data-period-value]');
    const startInput = exportForm.querySelector('[data-start-date]');
    const startLabel = exportForm.querySelector('[data-start-date-label]');
    const endInput = exportForm.querySelector('[data-end-date]');
    const endLabel = exportForm.querySelector('[data-end-date-label]');
    const summaryPeriod = exportForm.querySelector('[data-summary-period]');
    const summaryRange = exportForm.querySelector('[data-summary-range]');
    const summaryPayment = exportForm.querySelector('[data-summary-payment]');
    const summaryRental = exportForm.querySelector('[data-summary-rental]');
    const summaryStatus = exportForm.querySelector('[data-summary-status]');
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    const parseDate = (value) => {
        const [year, month, day] = value.split('-').map(Number);
        return new Date(year, month - 1, day);
    };

    const inputDate = (date) => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const displayDate = (date) => `${String(date.getDate()).padStart(2, '0')} ${monthNames[date.getMonth()]} ${date.getFullYear()}`;

    const updateRange = () => {
        if (!startInput.value) {
            startLabel.textContent = 'Pilih tanggal awal';
            endLabel.textContent = 'Tanggal akhir otomatis';
            endInput.value = '';
            summaryRange.textContent = 'Belum memilih tanggal';
            return;
        }

        const start = parseDate(startInput.value);
        const end = new Date(start);
        const period = periodValue.value;

        if (period === 'daily') end.setDate(end.getDate() + 1);
        if (period === 'weekly') end.setDate(end.getDate() + 6);
        if (period === 'monthly') end.setMonth(end.getMonth() + 1, end.getDate() - 1);
        if (period === 'yearly') end.setFullYear(end.getFullYear() + 1, end.getMonth(), end.getDate() - 1);

        startLabel.textContent = displayDate(start);
        endLabel.textContent = displayDate(end);
        endInput.value = inputDate(end);
        summaryRange.textContent = `${displayDate(start)} - ${displayDate(end)}`;
    };

    periodOptions?.addEventListener('click', (event) => {
        const button = event.target.closest('[data-period]');
        if (!button) return;

        periodValue.value = button.dataset.period;
        periodOptions.querySelectorAll('[data-period]').forEach((option) => option.classList.toggle('is-active', option === button));
        summaryPeriod.textContent = button.textContent.trim();
        updateRange();
    });

    startInput?.addEventListener('change', updateRange);
    startInput?.closest('.date-choice')?.addEventListener('click', () => {
        if (typeof startInput.showPicker === 'function') {
            startInput.showPicker();
        }
    });
    updateRange();

    document.addEventListener('click', (event) => {
        const openButton = event.target.closest('[data-open-picker]');
        const closeButton = event.target.closest('[data-close-picker]');
        const option = event.target.closest('[data-picker-option]');

        if (openButton) {
            document.querySelector(`[data-picker="${openButton.dataset.openPicker}"]`)?.removeAttribute('hidden');
            return;
        }

        if (closeButton) {
            closeButton.closest('[data-picker]')?.setAttribute('hidden', '');
            return;
        }

        if (!option) return;

        const type = option.dataset.pickerOption;
        const picker = option.closest('[data-picker]');
        picker.querySelectorAll('[data-picker-option]').forEach((item) => item.classList.toggle('is-selected', item === option));
        exportForm.querySelector(`[data-${type}-value]`).value = option.dataset.value;
        exportForm.querySelector(`[data-${type}-button-label]`).textContent = option.dataset.label;
        exportForm.querySelector(`[data-summary-${type}]`).textContent = option.dataset.label;

        if (type === 'status') {
            const dot = exportForm.querySelector('.picker-dot');
            dot.className = `picker-dot ${option.dataset.value}`;
        }

        picker.setAttribute('hidden', '');
    });
}
