<?php
require_once __DIR__ . '/../repositories/kategori_repository.php';

$currentPage = max(1, (int) ($_GET['p'] ?? 1));
$perPage = 10;
$products = getAdminCategoryProducts();
$totalProducts = count($products);
$totalPages = max(1, (int) ceil($totalProducts / $perPage));
$currentPage = min($currentPage, $totalPages);
$offset = ($currentPage - 1) * $perPage;
$visibleProducts = array_slice($products, $offset, $perPage);
$startNumber = $totalProducts === 0 ? 0 : $offset + 1;
$endNumber = min($offset + $perPage, $totalProducts);

function kategoriProdukPageUrl(int $page): string
{
    return 'index.php?' . http_build_query([
        'page' => 'kategori',
        'action' => 'produk',
        'p' => $page,
    ]);
}

function kategoriProdukPaginationRange(int $currentPage, int $totalPages): array
{
    $start = max(1, min($currentPage - 1, $totalPages - 2));
    $end = min($totalPages, $start + 2);

    return range($start, $end);
}
?>
<section class="kategori-card kategori-produk-card">
    <div class="kategori-produk-header">
        <h2>Listing Produk</h2>
    </div>

    <div class="kategori-table-wrap">
        <table class="kategori-table kategori-produk-table">
            <thead>
                <tr>
                    <th>Produk</th>
                    <th>Nama Toko</th>
                    <th>Kategori</th>
                    <th>Harga per hari</th>
                    <th>Stok</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($visibleProducts)): ?>
                    <tr>
                        <td class="kategori-empty" colspan="5">Data produk belum tersedia.</td>
                    </tr>
                <?php endif; ?>

                <?php foreach ($visibleProducts as $product): ?>
                    <tr>
                        <td><?= htmlspecialchars(adminProductName($product)) ?></td>
                        <td><?= htmlspecialchars(adminProductStore($product)) ?></td>
                        <td><?= htmlspecialchars(adminProductCategory($product)) ?></td>
                        <td><?= htmlspecialchars(adminProductPrice($product)) ?></td>
                        <td><?= adminProductStock($product) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <div class="kategori-footer">
        <p>Menampilkan <?= $startNumber ?>-<?= $endNumber ?> dari <?= $totalProducts ?> data</p>

        <div class="kategori-pagination">
            <a
                class="kategori-page-button <?= $currentPage <= 1 ? 'is-disabled' : '' ?>"
                href="<?= $currentPage <= 1 ? '#' : htmlspecialchars(kategoriProdukPageUrl($currentPage - 1)) ?>"
                aria-label="Halaman sebelumnya"
            >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M19 12H5"></path>
                    <path d="m12 19-7-7 7-7"></path>
                </svg>
            </a>

            <?php foreach (kategoriProdukPaginationRange($currentPage, $totalPages) as $pageNumber): ?>
                <a
                    class="kategori-page-button <?= $pageNumber === $currentPage ? 'is-active' : '' ?>"
                    href="<?= htmlspecialchars(kategoriProdukPageUrl($pageNumber)) ?>"
                >
                    <?= $pageNumber ?>
                </a>
            <?php endforeach; ?>

            <a
                class="kategori-page-button <?= $currentPage >= $totalPages ? 'is-disabled' : '' ?>"
                href="<?= $currentPage >= $totalPages ? '#' : htmlspecialchars(kategoriProdukPageUrl($currentPage + 1)) ?>"
                aria-label="Halaman berikutnya"
            >
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M5 12h14"></path>
                    <path d="m12 5 7 7-7 7"></path>
                </svg>
            </a>
        </div>
    </div>
</section>
