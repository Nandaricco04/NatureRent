<?php
require_once __DIR__ . '/../config/supabase.php';
require_once __DIR__ . '/../config/supabase_storage.php';

function supabaseFirstOk(array $paths): array
{
    foreach ($paths as $path) {
        $result = supabaseRequest($path);

        if ($result['ok'] && is_array($result['data'])) {
            return $result;
        }
    }

    return ['ok' => false, 'status' => 0, 'data' => [], 'error' => null];
}

function getDestinations(): array
{
    $query = http_build_query(['select' => '*']);

    $result = supabaseFirstOk([
        'destination?' . $query,
        'destinasi?' . $query,
    ]);

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    $destinations = $result['data'];

    usort($destinations, function (array $left, array $right): int {
        $leftId = $left['id_destination'] ?? $left['id_destinasi'] ?? $left['id'] ?? 0;
        $rightId = $right['id_destination'] ?? $right['id_destinasi'] ?? $right['id'] ?? 0;

        return (int) $leftId <=> (int) $rightId;
    });

    return $destinations;
}

function getLocations(): array
{
    $result = supabaseFirstOk([
        'lokasi?' . http_build_query([
            'select' => 'id_lokasi,nama_kota',
            'order' => 'nama_kota.asc',
        ]),
        'lokasi?' . http_build_query(['select' => '*']),
    ]);

    if (!$result['ok'] || !is_array($result['data'])) {
        return [];
    }

    return $result['data'];
}

function locationId(array $location): string
{
    foreach (['id_lokasi', 'lokasi_id', 'id'] as $key) {
        if (isset($location[$key])) {
            return (string) $location[$key];
        }
    }

    return '';
}

function locationName(array $location): string
{
    foreach (['nama_kota', 'nama_lokasi', 'lokasi', 'nama', 'name'] as $key) {
        if (!empty($location[$key])) {
            return (string) $location[$key];
        }
    }

    return 'Lokasi';
}

function destinationId(array $destination): string
{
    foreach (['id_destination', 'id_destinasi', 'id'] as $key) {
        if (isset($destination[$key])) {
            return (string) $destination[$key];
        }
    }

    return '';
}

function destinationTitle(array $destination): string
{
    foreach (['nama_destination', 'nama_destinasi', 'nama', 'title', 'judul', 'name'] as $key) {
        if (!empty($destination[$key])) {
            return (string) $destination[$key];
        }
    }

    return 'Destinasi';
}

function destinationImage(array $destination): string
{
    foreach (['gambar', 'image_url', 'foto', 'banner_url', 'url_gambar'] as $key) {
        if (!empty($destination[$key])) {
            return (string) $destination[$key];
        }
    }

    return '';
}

function destinationLocationName(array $destination, array $locations): string
{
    foreach (['nama_kota', 'nama_lokasi', 'lokasi_name', 'lokasi'] as $key) {
        if (!empty($destination[$key])) {
            return (string) $destination[$key];
        }
    }

    $locationId = (string) ($destination['lokasi_id'] ?? $destination['id_lokasi'] ?? '');

    if ($locationId === '') {
        return '-';
    }

    foreach ($locations as $location) {
        if (locationId($location) === $locationId) {
            return locationName($location);
        }
    }

    return '-';
}

function cleanDestinationFileName(string $name): string
{
    $extension = strtolower(pathinfo($name, PATHINFO_EXTENSION));
    $baseName = strtolower(pathinfo($name, PATHINFO_FILENAME));
    $baseName = preg_replace('/[^a-z0-9]+/', '-', $baseName) ?: 'destination';
    $baseName = trim($baseName, '-');

    return $baseName . '-' . time() . '.' . $extension;
}

function uploadDestinationImage(array $file): array
{
    $allowedTypes = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/jpg' => 'jpg',
    ];

    $mimeType = mime_content_type($file['tmp_name']) ?: ($file['type'] ?? '');

    if (!isset($allowedTypes[$mimeType])) {
        return ['ok' => false, 'error' => 'Format gambar harus JPG, PNG, atau JPEG.'];
    }

    if ((int) $file['size'] > 3 * 1024 * 1024) {
        return ['ok' => false, 'error' => 'Ukuran gambar maksimal 3 MB.'];
    }

    $objectPath = 'destinasi/' . cleanDestinationFileName($file['name']);

    foreach (['destinasi_images', 'destinasi_image'] as $bucket) {
        $upload = supabaseStorageUpload($bucket, $objectPath, $file['tmp_name'], $mimeType);

        if ($upload['ok']) {
            return ['ok' => true, 'url' => $upload['publicUrl']];
        }
    }

    return ['ok' => false, 'error' => 'Upload gambar gagal. Periksa bucket atau policy storage.'];
}

function storageObjectFromPublicUrl(string $url): ?array
{
    $marker = '/storage/v1/object/public/';
    $position = strpos($url, $marker);

    if ($position === false) {
        return null;
    }

    $path = substr($url, $position + strlen($marker));
    $parts = explode('/', $path, 2);

    if (count($parts) !== 2 || $parts[0] === '' || $parts[1] === '') {
        return null;
    }

    return [
        'bucket' => rawurldecode($parts[0]),
        'path' => rawurldecode($parts[1]),
    ];
}

function deleteDestinationImage(string $imageUrl): void
{
    $object = storageObjectFromPublicUrl($imageUrl);

    if ($object === null) {
        return;
    }

    supabaseStorageDelete($object['bucket'], $object['path']);
}

function createDestination(string $name, int $locationId, string $imageUrl): array
{
    return supabaseRequest('destination', 'POST', [
        'lokasi_id' => $locationId,
        'nama_destination' => trim($name),
        'gambar' => $imageUrl,
    ]);
}

function updateDestination(int $id, string $name, int $locationId, string $imageUrl): array
{
    return supabaseRequest('destination?id_destination=eq.' . $id, 'PATCH', [
        'lokasi_id' => $locationId,
        'nama_destination' => trim($name),
        'gambar' => $imageUrl,
    ]);
}

function deleteDestination(int $id): array
{
    return supabaseRequest('destination?id_destination=eq.' . $id, 'DELETE');
}
