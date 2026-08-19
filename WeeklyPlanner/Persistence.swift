import Foundation
import SwiftData

/// Şemanın sürümlenmiş hâli.
///
/// Şu an tek sürüm var. Alan **eklemek** hafif göçle kendiliğinden hallolur,
/// burada bir şey yapmak gerekmez. Ama bir modeli yeniden adlandırdığında ya
/// da bir alanı sildiğinde:
///   1. O günkü model tanımlarının kopyasını `SchemaV1` içine taşı,
///   2. güncel tipleri gösteren bir `SchemaV2` ekle,
///   3. aradaki farkı `PlannerMigrationPlan.stages`e bir `MigrationStage`
///      olarak yaz.
/// Bu adım atlanırsa SwiftData depoyu açamaz ve uygulama kullanıcının
/// cihazında açılmaz hâle gelir.
enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [WeeklyTask.self, Todo.self, Goal.self, SubTask.self, Habit.self]
    }
}

enum PlannerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

enum Persistence {

    static let schema = Schema(versionedSchema: SchemaV1.self)

    /// SwiftData'nın varsayılan konumu. Elle veriyoruz ki depo açılamadığında
    /// dosyayı bulup kenara alabilelim.
    private static var storeURL: URL {
        URL.applicationSupportDirectory.appending(path: "default.store")
    }

    /// Uygulamanın gerçek (diske yazan) veri kabı.
    ///
    /// Depo açılamazsa uygulamayı çökertmiyoruz: bozuk dosya kenara alınıp
    /// temiz bir kapla açılıyor. Eski dosya diskte kalır, yani veri silinmez —
    /// kurtarılabilir durumda bekler.
    static func makeContainer() -> ModelContainer {
        do {
            return try openStore()
        } catch {
            print("Veri deposu açılamadı:", error)

            let salvaged = setAside(storeURL)
            do {
                let container = try openStore()
                print("Temiz depo oluşturuldu. Eski dosya:", salvaged?.lastPathComponent ?? "yok")
                return container
            } catch {
                // Diske hiç yazamıyoruz (dolu disk, izin sorunu...). Bellek içi
                // kaba düşüyoruz: uygulama açılır ve kullanılabilir kalır, ama
                // bu oturumda yazılanlar kalıcı olmaz.
                print("Diske yazılamıyor, bellek içi kaba düşülüyor:", error)
                return inMemoryContainer()
            }
        }
    }

    private static func openStore() throws -> ModelContainer {
        let directory = storeURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(
            for: schema,
            migrationPlan: PlannerMigrationPlan.self,
            configurations: configuration
        )
    }

    /// Açılamayan depoyu zaman damgalı bir adla yeniden adlandırır.
    /// Yeni depo eski WAL/SHM yan dosyalarına takılmasın diye onlar da taşınır.
    private static func setAside(_ url: URL) -> URL? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        let stamp = Int(Date().timeIntervalSince1970)
        let name = url.deletingPathExtension().lastPathComponent
        let target = url
            .deletingLastPathComponent()
            .appending(path: "\(name)-bozuk-\(stamp).\(url.pathExtension)")

        do {
            try fileManager.moveItem(at: url, to: target)
        } catch {
            print("Bozuk depo taşınamadı:", error)
            return nil
        }

        for suffix in ["-wal", "-shm"] {
            let side = URL(filePath: url.path() + suffix)
            guard fileManager.fileExists(atPath: side.path) else { continue }
            try? fileManager.moveItem(at: side, to: URL(filePath: target.path() + suffix))
        }

        return target
    }

    private static func inMemoryContainer() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // Bellek içi kap diskten bağımsız; şema geçerli olduğu sürece
        // başarısız olması için bir sebep kalmıyor.
        return try! ModelContainer(for: schema, configurations: configuration)
    }

    /// Preview'lar için belleğe yazan, diske dokunmayan kap.
    @MainActor
    static let previewContainer: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Preview ModelContainer oluşturulamadı: \(error)")
        }
    }()
}
