<?php
// repositories/informasi_repository.php
require_once __DIR__ . '/../config/supabase.php';

class InformasiRepository {

    private string $table = 'informasi';

    // ── Ambil semua informasi ──
    public function getAllInformasi(): array {
        $result = supabaseRequest($this->table . '?order=id_informasi.asc');
        return ($result['ok'] && is_array($result['data'])) ? $result['data'] : [];
    }

    // ── Ambil satu informasi by ID ──
    public function getInformasiById(int $id): ?array {
        $result = supabaseRequest($this->table . '?id_informasi=eq.' . $id . '&limit=1');
        $data   = $result['data'];
        return (!empty($data) && isset($data[0])) ? $data[0] : null;
    }

    // ── Tambah informasi baru ──
    public function createInformasi(string $judul, string $deskripsi): bool {
        // Ambil id dari session admin
        $userId = $_SESSION['admin']['id'] ?? null;

        $payload = [
            'title'       => $judul,
            'description' => $deskripsi,
        ];

        if ($userId !== null) {
            $payload['user_id'] = (int) $userId;
        }

        $result = supabaseRequest($this->table, 'POST', $payload);
        return $result['ok'];
    }

    // ── Update informasi ──
    public function updateInformasi(int $id, string $judul, string $deskripsi): bool {
        $result = supabaseRequest($this->table . '?id_informasi=eq.' . $id, 'PATCH', [
            'title'       => $judul,
            'description' => $deskripsi,
            'updated_at'  => gmdate('Y-m-d\TH:i:s\Z'),
        ]);
        return $result['ok'];
    }

    // ── Hapus informasi ──
    public function deleteInformasi(int $id): bool {
        $result = supabaseRequest($this->table . '?id_informasi=eq.' . $id, 'DELETE');
        return $result['ok'];
    }
}