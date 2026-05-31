<?php
require_once __DIR__ . '/../config/supabase.php';

function getAllOwners(): array
{
    $query = http_build_query([
        'select' => 'id_owner,nama_toko,nomor_telepon,status_verifikasi,lokasi(nama_kota),users(email)',
        'order'  => 'id_owner.asc',
    ]);

    $result = supabaseRequest('owner?' . $query);

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function countOwnerByStatus(): array
{
    $result = supabaseRequest('owner?select=status_verifikasi');

    $counts = [
        'approved' => 0,
        'pending'  => 0,
        'rejected' => 0,
        'inactive' => 0,
    ];

    if (!$result['ok'] || !is_array($result['data'])) {
        return $counts;
    }

    foreach ($result['data'] as $row) {
        $status = strtolower($row['status_verifikasi'] ?? '');
        if (isset($counts[$status])) {
            $counts[$status]++;
        }
    }

    return $counts;
}

function findOwnerById(int $id): ?array
{
    $query = http_build_query([
        'select' => '*,lokasi(nama_kota),users(email)',
        'id_owner' => 'eq.' . $id,
        'limit'    => '1',
    ]);

    $result = supabaseRequest('owner?' . $query);

    if (!$result['ok'] || empty($result['data'])) {
        return null;
    }

    return $result['data'][0];
}

function updateOwnerStatus(int $id, string $status): array
{
    return supabaseRequest('owner?id_owner=eq.' . $id, 'PATCH', [
        'status_verifikasi' => $status,
    ]);
}

function updateOwner(int $id, array $payload): array
{
    return supabaseRequest('owner?id_owner=eq.' . $id, 'PATCH', $payload);
}

function deactivateOwner(int $id): array
{
    return updateOwnerStatus($id, 'inactive');
}

function activateOwner(int $id): array
{
    return updateOwnerStatus($id, 'approved');
}