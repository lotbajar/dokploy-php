<?php
declare(strict_types=1);

// --- Config ---
$dbFile = __DIR__ . '/database/app.sqlite';

if (!file_exists($dbFile)) {
    http_response_code(500);
    echo "Database file not found.";
    exit;
}

$pdo = new PDO('sqlite:' . $dbFile, null, null, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
]);

$path   = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?? '/';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// Healthcheck blijft apart
if ($path === '/health') {
    header('Content-Type: text/plain');
    echo 'OK';
    exit;
}

// POST naar / → toevoegen
if ($path === '/' && $method === 'POST') {
    $text = trim($_POST['text'] ?? '');

    if ($text !== '') {
        $stmt = $pdo->prepare(
            'INSERT INTO notes (text, created_at) VALUES (:text, :created_at)'
        );
        $stmt->execute([
            ':text' => $text,
            ':created_at' => gmdate('c'),
        ]);
    }

    // PRG pattern: voorkomt dubbele submits
    header('Location: /', true, 303);
    exit;
}

// GET / → tonen
$notes = $pdo
    ->query('SELECT id, text, created_at FROM notes ORDER BY id DESC')
    ->fetchAll(PDO::FETCH_ASSOC);

header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>PHP + SQLite</title>
  <style>
    body { font-family: system-ui; max-width: 800px; margin: 40px auto; }
    form { display: flex; gap: 8px; margin-bottom: 20px; }
    input { flex: 1; padding: 8px; }
    button { padding: 8px 12px; }
    .note { border: 1px solid #ddd; padding: 10px; margin-bottom: 10px; }
    small { color: #666; }
  </style>
</head>
<body>
  <h1>PHP + SQLite</h1>

  <form method="post" action="/">
    <input name="text" placeholder="Add a note…" required />
    <button>Add</button>
  </form>

  <?php foreach ($notes as $n): ?>
    <div class="note">
      <?= htmlspecialchars($n['text']) ?><br>
      <small><?= htmlspecialchars($n['created_at']) ?></small>
    </div>
  <?php endforeach; ?>
<?php
php_info();
?>
</body>
</html>
