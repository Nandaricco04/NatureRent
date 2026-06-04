<?php
require_once __DIR__ . '/../config/supabase.php';

class KomplainRepository
{
    public static function getAll(string $status = 'Semua', string $keyword = ''): array
    {
        $query = 'support?order=created_at.desc&select=*';

        if ($status !== 'Semua') {
            $query .= '&status=eq.' . urlencode($status);
        }

        if ($keyword !== '') {
            $like   = '%' . $keyword . '%';
            $query .= '&or=(nama_pengguna.ilike.' . urlencode($like) . ',id_pesanan.ilike.' . urlencode($like) . ')';
        }

        error_log('Query: ' . $query); // ← tambahkan ini
        $result = supabaseRequest($query);
        error_log('Result: ' . json_encode($result)); // ← dan ini

        $result = supabaseRequest($query);

        if (!$result['ok'] || !is_array($result['data'])) {
            return [];
        }

        return $result['data'];
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

// ── Hitung jumlah komplain per status ──────────────────────────────────────
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

// ── Ambil detail komplain by id ────────────────────────────────────────────
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

// ── Update status komplain ─────────────────────────────────────────────────
function updateKomplainStatus(int $id, string $status): array
{
    return supabaseRequest('support?id_support=eq.' . $id, 'PATCH', [
        'status' => $status,
    ]);
}

// ── Hapus komplain ─────────────────────────────────────────────────────────
function deleteKomplain(int $id): array
{
    return supabaseRequest('support?id_support=eq.' . $id, 'DELETE');
}