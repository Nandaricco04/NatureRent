<?php
require_once __DIR__ . '/../config/supabase.php';

function getTaxTransactions(): array
{
    $transactions = fetchTaxTransactionRows();
    $items = fetchTaxItemRows();
    $products = fetchTaxProducts();
    $owners = fetchTaxOwners();

    $itemsByTransaction = [];
    foreach ($items as $item) {
        $transactionId = (string) ($item['transaksi_id'] ?? '');
        if ($transactionId === '') {
            continue;
        }
        $itemsByTransaction[$transactionId][] = $item;
    }

    $productById = [];
    foreach ($products as $product) {
        $productById[(string) ($product['id_product'] ?? '')] = $product;
    }

    $ownerById = [];
    foreach ($owners as $owner) {
        $ownerById[(string) ($owner['id_owner'] ?? '')] = $owner;
    }

    return array_values(array_map(
        function (array $transaction) use ($itemsByTransaction, $productById, $ownerById): array {
            $transactionId = (string) ($transaction['id_transaksi'] ?? '');
            $transactionItems = $itemsByTransaction[$transactionId] ?? [];
            $firstItem = $transactionItems[0] ?? [];
            $product = $productById[(string) ($firstItem['product_id'] ?? '')] ?? [];
            $owner = $ownerById[(string) ($product['owner_id'] ?? '')] ?? [];

            return array_merge($transaction, [
                '_items' => $transactionItems,
                '_owner' => $owner,
            ]);
        },
        $transactions
    ));
}

function findTaxTransactionById(string $id): ?array
{
    if ($id === '') {
        return null;
    }

    foreach (getTaxTransactions() as $transaction) {
        if ((string) ($transaction['id_transaksi'] ?? '') === $id) {
            return $transaction;
        }
    }

    return null;
}

function fetchTaxTransactionRows(): array
{
    $result = supabaseRequest('transaksi?' . http_build_query([
        'select' => 'id_transaksi,pajak,status_pajak,bukti_pajak,total_harga,payment_method,status_pesanan,created_at',
        'order' => 'created_at.desc',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return array_values(array_filter($result['data'], function (array $row): bool {
        return !taxOrderIsCancelled($row) && taxAmount($row) > 0;
    }));
}

function fetchTaxItemRows(): array
{
    $result = supabaseRequest('transaksi_item?' . http_build_query([
        'select' => 'transaksi_id,product_id,nama_produk',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function fetchTaxProducts(): array
{
    $result = supabaseRequest('products?' . http_build_query([
        'select' => 'id_product,owner_id,name',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function fetchTaxOwners(): array
{
    $result = supabaseRequest('owner?' . http_build_query([
        'select' => 'id_owner,nama_toko',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function updateTaxStatus(string $transactionId, string $status): array
{
    if ($transactionId === '') {
        return ['ok' => false, 'status' => 0, 'data' => null, 'error' => 'ID transaksi kosong'];
    }

    return supabaseRequest('transaksi?id_transaksi=eq.' . rawurlencode($transactionId), 'PATCH', [
        'status_pajak' => $status,
        'updated_at' => date('c'),
    ]);
}

function taxTransactionCode(array $transaction): string
{
    $number = (int) ($transaction['id_transaksi'] ?? 0);
    return 'ID' . str_pad((string) $number, 7, '0', STR_PAD_LEFT);
}

function taxStoreName(array $transaction): string
{
    return (string) ($transaction['_owner']['nama_toko'] ?? 'Toko');
}

function taxProductNames(array $transaction): string
{
    $items = $transaction['_items'] ?? [];
    $names = [];

    foreach ($items as $item) {
        $name = trim((string) ($item['nama_produk'] ?? ''));
        if ($name !== '') {
            $names[] = $name;
        }
    }

    return $names ? implode(', ', array_unique($names)) : 'Alat';
}

function taxAmount(array $transaction): int
{
    if (taxOrderIsCancelled($transaction)) {
        return 0;
    }

    return (int) ($transaction['pajak'] ?? 0);
}

function taxOrderStatus(array $transaction): string
{
    return strtolower(trim((string) ($transaction['status_pesanan'] ?? '')));
}

function taxOrderIsCancelled(array $transaction): bool
{
    return in_array(taxOrderStatus($transaction), ['dibatalkan', 'batal'], true);
}

function taxStatus(array $transaction): string
{
    return (string) ($transaction['status_pajak'] ?? 'belum_dibayar');
}

function taxStatusLabel(string $status): string
{
    return match ($status) {
        'sudah_dibayar' => 'Sudah Bayar',
        'menunggu_verifikasi' => 'Menunggu',
        'gagal' => 'Gagal',
        'belum_dibayar' => 'Belum Bayar',
        default => $status !== '' ? $status : '-',
    };
}

function taxStatusClass(string $status): string
{
    return match ($status) {
        'sudah_dibayar' => 'paid',
        'menunggu_verifikasi' => 'waiting',
        'gagal' => 'failed',
        default => 'default',
    };
}

function taxPaymentMethod(array $transaction): string
{
    return 'QRIS';
}

function taxProofUrl(array $transaction): string
{
    return (string) ($transaction['bukti_pajak'] ?? '');
}

function taxProofName(array $transaction): string
{
    $proof = taxProofUrl($transaction);

    if ($proof === '') {
        return '-';
    }

    $path = parse_url($proof, PHP_URL_PATH);
    $basename = basename((string) $path);

    return $basename !== '' ? rawurldecode($basename) : 'bukti pembayaran';
}

function formatTaxMoney($value): string
{
    return 'Rp ' . number_format((int) $value, 0, ',', '.');
}
