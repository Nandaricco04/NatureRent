<?php
require_once __DIR__ . '/../config/supabase.php';

class KomplainRepository
{
    public static function getAll(string $status = 'Semua', string $keyword = ''): array
    {
        $query = 'support?order=created_at.desc&select=*';

        if ($status !== 'Semua' && $status !== '') {
            $query .= '&status=eq.' . urlencode($status);
        }

        $result = supabaseRequest($query);

        if (!$result['ok'] || !is_array($result['data'])) {
            return [];
        }

        $data = $result['data'];

        if ($keyword !== '') {
            $keyword = strtolower($keyword);
            $data = array_values(array_filter($data, function ($row) use ($keyword) {
                $nama = strtolower($row['nama_pengguna'] ?? '');
                $id   = strtolower($row['id_pesanan']    ?? '');
                return str_contains($nama, $keyword) || str_contains($id, $keyword);
            }));
        }

        return $data;
    }

    public static function getById(int $id): ?array
    {
        $result = supabaseRequest('support?id_support=eq.' . $id . '&limit=1&select=*');

        if (!$result['ok'] || empty($result['data'])) {
            return null;
        }

        return $result['data'][0];
    }

    public static function getSummary(): array
    {
        $summary = ['total' => 0, 'menunggu' => 0, 'diproses' => 0, 'selesai' => 0];

        $result = supabaseRequest('support?select=status');

        if (!$result['ok'] || !is_array($result['data'])) {
            return $summary;
        }

        foreach ($result['data'] as $row) {
            $summary['total']++;
            $key = strtolower($row['status'] ?? '');
            if (isset($summary[$key])) {
                $summary[$key]++;
            }
        }

        return $summary;
    }

    public static function updateStatus(int $id, string $status): bool
    {
        $result = supabaseRequest(
            'support?id_support=eq.' . $id,
            'PATCH',
            ['status' => $status]
        );
        return $result['ok'];
    }

    public static function remove(int $id): bool
    {
        $result = supabaseRequest(
            'support?id_support=eq.' . $id,
            'DELETE'
        );
        return $result['ok'];
    }
}

function countKomplainByStatus(): array
{
    $result = supabaseRequest('support?select=status');

    $counts = [
        'total'    => 0,
        'menunggu' => 0,
        'diproses' => 0,
        'selesai'  => 0,
    ];

    if (!$result['ok'] || !is_array($result['data'])) {
        return $counts;
    }

    foreach ($result['data'] as $row) {
        $counts['total']++;
        $status = strtolower($row['status'] ?? 'menunggu');
        if (isset($counts[$status])) {
            $counts[$status]++;
        }
    }

    return $counts;
}

function findKomplainById(int $id): ?array
{
    $query = http_build_query([
        'select'     => '*',
        'id_support' => 'eq.' . $id,
        'limit'      => '1',
    ]);

    $result = supabaseRequest('support?' . $query);

    if (!$result['ok'] || empty($result['data'])) {
        return null;
    }

    return $result['data'][0];
}

function updateKomplainStatus(int $id, string $status): array
{
    return supabaseRequest('support?id_support=eq.' . $id, 'PATCH', [
        'status' => $status,
    ]);
}

function deleteKomplain(int $id): array
{
    return supabaseRequest('support?id_support=eq.' . $id, 'DELETE');
}