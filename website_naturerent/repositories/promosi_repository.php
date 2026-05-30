<?php
require_once __DIR__ . '/../config/supabase.php';

function getPromotionRows(): array
{
    syncExpiredPromotions();

    $result = supabaseRequest('iklan_sewa?' . http_build_query([
        'select' => '*',
        'order' => 'created_at.desc',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function getPromotionProducts(): array
{
    $result = supabaseRequest('products?' . http_build_query([
        'select' => 'id_product,name,owner_id,iklan',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function getPromotionOwners(): array
{
    $result = supabaseRequest('owner?' . http_build_query([
        'select' => 'id_owner,nama_toko',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function getPromotionPackages(): array
{
    $result = supabaseRequest('paket_iklan?' . http_build_query([
        'select' => '*',
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function getPromotions(): array
{
    $products = getPromotionProducts();
    $owners = getPromotionOwners();
    $packages = getPromotionPackages();

    $productById = [];
    foreach ($products as $product) {
        $productById[(string) ($product['id_product'] ?? '')] = $product;
    }

    $ownerById = [];
    foreach ($owners as $owner) {
        $ownerById[(string) ($owner['id_owner'] ?? '')] = $owner;
    }

    $packageById = [];
    foreach ($packages as $package) {
        $packageById[(string) promotionPackageId($package)] = $package;
    }

    $rows = getPromotionRows();

    return array_map(function (array $row) use ($productById, $ownerById, $packageById): array {
        $product = $productById[(string) ($row['alat_id'] ?? '')] ?? [];
        $owner = $ownerById[(string) ($product['owner_id'] ?? '')] ?? [];
        $package = $packageById[(string) ($row['paket_iklan_id'] ?? '')] ?? [];

        return array_merge($row, [
            '_product' => $product,
            '_owner' => $owner,
            '_package' => $package,
        ]);
    }, $rows);
}

function findPromotionById(string $id): ?array
{
    syncExpiredPromotions();

    $rowResult = supabaseRequest('iklan_sewa?' . http_build_query([
        'select' => '*',
        'id_sewa' => 'eq.' . $id,
        'limit' => '1',
    ]));

    if (!$rowResult['ok'] || empty($rowResult['data'][0]) || !is_array($rowResult['data'][0])) {
        return null;
    }

    $row = $rowResult['data'][0];
    $product = findPromotionProductById((string) ($row['alat_id'] ?? ''));
    $owner = findPromotionOwnerById((string) ($product['owner_id'] ?? ''));
    $package = findPromotionPackageById((string) ($row['paket_iklan_id'] ?? ''));

    return array_merge($row, [
        '_product' => $product,
        '_owner' => $owner,
        '_package' => $package,
    ]);
}

function findPromotionProductById(string $id): array
{
    if ($id === '') {
        return [];
    }

    $result = supabaseRequest('products?' . http_build_query([
        'select' => 'id_product,name,owner_id,iklan',
        'id_product' => 'eq.' . $id,
        'limit' => '1',
    ]));

    if (!$result['ok'] || empty($result['data'][0]) || !is_array($result['data'][0])) {
        return [];
    }

    return $result['data'][0];
}

function findPromotionOwnerById(string $id): array
{
    if ($id === '') {
        return [];
    }

    $result = supabaseRequest('owner?' . http_build_query([
        'select' => 'id_owner,nama_toko',
        'id_owner' => 'eq.' . $id,
        'limit' => '1',
    ]));

    if (!$result['ok'] || empty($result['data'][0]) || !is_array($result['data'][0])) {
        return [];
    }

    return $result['data'][0];
}

function findPromotionPackageById(string $id): array
{
    if ($id === '') {
        return [];
    }

    foreach (getPromotionPackages() as $package) {
        if (promotionPackageId($package) === $id) {
            return $package;
        }
    }

    return [];
}

function promotionId(array $promotion): string
{
    foreach (['id_sewa', 'id_iklan_sewa', 'id'] as $key) {
        if (isset($promotion[$key])) {
            return (string) $promotion[$key];
        }
    }

    return '';
}

function promotionProductName(array $promotion): string
{
    return (string) ($promotion['_product']['name'] ?? 'Alat');
}

function promotionStoreName(array $promotion): string
{
    return (string) ($promotion['_owner']['nama_toko'] ?? 'Toko');
}

function promotionPackageId(array $package): string
{
    foreach (['id_paket_iklan', 'id_paket', 'id'] as $key) {
        if (isset($package[$key])) {
            return (string) $package[$key];
        }
    }

    return '';
}

function promotionDurationLabel(array $promotion): string
{
    $package = $promotion['_package'] ?? [];
    $duration = $package['durasi_hari'] ?? $package['durasi'] ?? $package['hari'] ?? null;

    if ($duration === null || $duration === '') {
        return '';
    }

    return (int) $duration . ' hari';
}

function promotionStatus(array $promotion): string
{
    return (string) ($promotion['status'] ?? '-');
}

function promotionStatusLabel(string $status): string
{
    return match ($status) {
        'menunggu_verifikasi' => 'Menunggu',
        'aktif' => 'Aktif',
        'ditolak' => 'Ditolak',
        'selesai' => 'Selesai',
        default => $status !== '' ? $status : '-',
    };
}

function promotionStatusClass(string $status): string
{
    return match ($status) {
        'menunggu_verifikasi' => 'waiting',
        'aktif' => 'active',
        'ditolak' => 'rejected',
        'selesai' => 'finished',
        default => 'default',
    };
}

function promotionProofUrl(array $promotion): string
{
    return (string) ($promotion['bukti_pembayaran'] ?? '');
}

function promotionProofName(array $promotion): string
{
    $proof = promotionProofUrl($promotion);

    if ($proof === '') {
        return '-';
    }

    $path = parse_url($proof, PHP_URL_PATH);
    $basename = basename((string) $path);

    return $basename !== '' ? rawurldecode($basename) : 'bukti pembayaran';
}

function formatPromotionMoney($value): string
{
    return 'Rp. ' . number_format((int) $value, 0, ',', '.');
}

function formatPromotionDate($value): string
{
    if (!$value) {
        return '-';
    }

    $timestamp = strtotime((string) $value);

    if (!$timestamp) {
        return '-';
    }

    return date('d-m-Y', $timestamp);
}

function deletePromotion(string $id): array
{
    return supabaseRequest('iklan_sewa?id_sewa=eq.' . rawurlencode($id), 'DELETE');
}

function updatePromotionStatus(array $promotion, string $status): array
{
    $id = promotionId($promotion);

    if ($id === '') {
        return ['ok' => false, 'status' => 0, 'data' => null, 'error' => 'ID promosi kosong'];
    }

    $result = supabaseRequest('iklan_sewa?id_sewa=eq.' . rawurlencode($id), 'PATCH', [
        'status' => $status,
        'updated_at' => date('c'),
    ]);

    if ($result['ok']) {
        setPromotionProductActive($promotion, $status === 'aktif');
    }

    return $result;
}

function setPromotionProductActive(array $promotion, bool $active): void
{
    $productId = $promotion['alat_id'] ?? null;

    if ($productId === null || $productId === '') {
        return;
    }

    supabaseRequest('products?id_product=eq.' . rawurlencode((string) $productId), 'PATCH', [
        'iklan' => $active,
    ]);
}

function setPromotionProductInactive(array $promotion): void
{
    setPromotionProductActive($promotion, false);
}

function syncExpiredPromotions(): void
{
    static $synced = false;

    if ($synced) {
        return;
    }

    $synced = true;
    $now = date('c');
    $result = supabaseRequest('iklan_sewa?' . http_build_query([
        'select' => 'id_sewa,alat_id,tanggal_selesai,status',
        'status' => 'eq.aktif',
        'tanggal_selesai' => 'lt.' . $now,
    ]));

    if (!$result['ok'] || !is_array($result['data'])) {
        return;
    }

    foreach ($result['data'] as $promotion) {
        if (!is_array($promotion)) {
            continue;
        }

        $id = promotionId($promotion);

        if ($id === '') {
            continue;
        }

        supabaseRequest('iklan_sewa?id_sewa=eq.' . rawurlencode($id), 'PATCH', [
            'status' => 'selesai',
            'updated_at' => $now,
        ]);

        setPromotionProductInactive($promotion);
    }
}
