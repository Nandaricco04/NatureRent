<?php
require_once __DIR__ . '/../config/supabase.php';

function getAdminTransactions(): array
{
    $transactions = fetchAdminTransactionRows();
    $items = fetchAdminTransactionItems();
    $products = fetchAdminTransactionProducts();
    $owners = fetchAdminTransactionOwners();
    $users = fetchAdminTransactionUsers();

    $itemsByTransaction = [];
    foreach ($items as $item) {
        $itemsByTransaction[(string) ($item['transaksi_id'] ?? '')][] = $item;
    }

    $productsById = [];
    foreach ($products as $product) {
        $productsById[(string) ($product['id_product'] ?? '')] = $product;
    }

    $ownersById = [];
    foreach ($owners as $owner) {
        $ownersById[(string) ($owner['id_owner'] ?? '')] = $owner;
    }

    $usersById = [];
    foreach ($users as $user) {
        $usersById[(string) ($user['id_user'] ?? '')] = $user;
    }

    return array_values(array_map(
        function (array $transaction) use ($itemsByTransaction, $productsById, $ownersById, $usersById): array {
            $transactionId = (string) ($transaction['id_transaksi'] ?? '');
            $transactionItems = $itemsByTransaction[$transactionId] ?? [];
            $storeNames = [];

            foreach ($transactionItems as $item) {
                $product = $productsById[(string) ($item['product_id'] ?? '')] ?? [];
                $owner = $ownersById[(string) ($product['owner_id'] ?? '')] ?? [];
                $storeName = trim((string) ($owner['nama_toko'] ?? ''));

                if ($storeName !== '') {
                    $storeNames[] = $storeName;
                }
            }

            return array_merge($transaction, [
                '_items' => $transactionItems,
                '_user' => $usersById[(string) ($transaction['user_id'] ?? '')] ?? [],
                '_store_names' => array_values(array_unique($storeNames)),
            ]);
        },
        $transactions
    ));
}

function fetchAdminTransactionRows(): array
{
    return adminTransactionData('transaksi?' . http_build_query([
        'select' => 'id_transaksi,user_id,tanggal_transaksi,payment_method,status_pesanan,total_harga,created_at',
        'order' => 'created_at.desc',
    ]));
}

function fetchAdminTransactionItems(): array
{
    return adminTransactionData('transaksi_item?' . http_build_query([
        'select' => 'transaksi_id,product_id,nama_produk',
    ]));
}

function fetchAdminTransactionProducts(): array
{
    return adminTransactionData('products?' . http_build_query([
        'select' => 'id_product,owner_id',
    ]));
}

function fetchAdminTransactionOwners(): array
{
    return adminTransactionData('owner?' . http_build_query([
        'select' => 'id_owner,nama_toko',
    ]));
}

function fetchAdminTransactionUsers(): array
{
    return adminTransactionData('users?' . http_build_query([
        'select' => 'id_user,nama',
    ]));
}

function adminTransactionData(string $path): array
{
    $result = supabaseRequest($path);

    return $result['ok'] && is_array($result['data']) ? $result['data'] : [];
}

function adminTransactionCode(array $transaction): string
{
    return 'ID' . str_pad((string) ($transaction['id_transaksi'] ?? ''), 7, '0', STR_PAD_LEFT);
}

function adminTransactionUser(array $transaction): string
{
    return (string) ($transaction['_user']['nama'] ?? 'Pengguna');
}

function adminTransactionStores(array $transaction): string
{
    $stores = $transaction['_store_names'] ?? [];

    return $stores ? implode(', ', $stores) : 'Rental';
}

function adminTransactionProducts(array $transaction): string
{
    $names = [];

    foreach ($transaction['_items'] ?? [] as $item) {
        $name = trim((string) ($item['nama_produk'] ?? ''));

        if ($name !== '') {
            $names[] = $name;
        }
    }

    return $names ? implode(', ', array_unique($names)) : 'Produk';
}

function adminTransactionDate(array $transaction): ?DateTimeImmutable
{
    $value = $transaction['tanggal_transaksi'] ?? $transaction['created_at'] ?? null;

    if (!$value) {
        return null;
    }

    try {
        return new DateTimeImmutable((string) $value);
    } catch (Exception $exception) {
        return null;
    }
}

function adminTransactionStatus(array $transaction): string
{
    $status = strtolower(trim((string) ($transaction['status_pesanan'] ?? 'dipesan')));

    return match ($status) {
        'batal' => 'dibatalkan',
        'selesai', 'completed' => 'selesai',
        'diambil', 'disewa' => 'diambil',
        'dibatalkan', 'cancelled' => 'dibatalkan',
        'menunggu', 'menunggu_konfirmasi' => 'dipesan',
        default => 'dipesan',
    };
}

function adminTransactionStatusLabel(string $status): string
{
    return match ($status) {
        'diambil' => 'Diambil',
        'selesai' => 'Selesai',
        'dibatalkan' => 'Dibatalkan',
        default => 'Dipesan',
    };
}

function formatAdminTransactionMoney($value): string
{
    return 'Rp' . number_format((int) $value, 0, ',', '.');
}
