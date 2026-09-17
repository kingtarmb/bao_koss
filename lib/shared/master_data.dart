class BatchDefinition {
  const BatchDefinition({
    required this.id,
    required this.name,
    required this.mentor,
    required this.focus,
    required this.description,
    required this.order,
  });

  final String id;
  final String name;
  final String mentor;
  final String focus;
  final String description;
  final int order;

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'mentor': mentor,
    'focus': focus,
    'description': description,
    'order': order,
    'active': true,
    'createdAt': null,
  };
}

class TrainingDefinition {
  const TrainingDefinition({
    required this.id,
    required this.batchId,
    required this.title,
    required this.description,
    required this.durationHours,
    required this.level,
    required this.order,
  });

  final String id;
  final String batchId;
  final String title;
  final String description;
  final int durationHours;
  final String level;
  final int order;

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'batchId': batchId,
    'title': title,
    'description': description,
    'durationHours': durationHours,
    'level': level,
    'order': order,
    'active': true,
    'createdAt': null,
  };
}

const List<BatchDefinition> defaultBatches = [
  BatchDefinition(
    id: 'batch-alchimie',
    name: 'Batch Prépa',
    mentor: 'Mamadou Sarr',
    focus: 'Préparation et formulation',
    description:
        'Techniques de mélange, dosage et sécurité des traitements de terrain.',
    order: 1,
  ),
  BatchDefinition(
    id: 'batch-traitement',
    name: 'Batch Traitement',
    mentor: 'Abdoul Karim',
    focus: 'Traitements phytosanitaires',
    description:
        'Bon usage des produits, protection du personnel et gestion du site.',
    order: 2,
  ),
  BatchDefinition(
    id: 'batch-semis',
    name: 'Batch Semis',
    mentor: 'Nicolas Demba',
    focus: 'Planification des semis',
    description:
        'Choix de la densité, préparation du sol et calendrier agricole.',
    order: 3,
  ),
  BatchDefinition(
    id: 'batch-recolte',
    name: 'Batch Récolte',
    mentor: 'Mariam Diallo',
    focus: 'Récolte et manutention',
    description: 'Préparation, collecte, tri et conservation des récoltes.',
    order: 4,
  ),
  BatchDefinition(
    id: 'batch-entretien',
    name: 'Batch Entretien',
    mentor: 'Oumar Diop',
    focus: 'Entretien des parcelles',
    description:
        'Contrôle du niveau d’eau, élimination des mauvaises herbes et suivi du terrain.',
    order: 5,
  ),
  BatchDefinition(
    id: 'batch-irrigation',
    name: 'Batch Irrigation',
    mentor: 'Sidy Kane',
    focus: 'Gestion de l’eau',
    description:
        'Planification d’irrigation, débit et maintenance des systèmes.',
    order: 6,
  ),
  BatchDefinition(
    id: 'batch-pulverisation',
    name: 'Batch Pulvérisation',
    mentor: 'Issa Barry',
    focus: 'Pulvérisation et sécurité',
    description:
        'Calibration, tenue des équipements et protection des cultures.',
    order: 7,
  ),
  BatchDefinition(
    id: 'batch-stockage',
    name: 'Batch Stockage',
    mentor: 'Awa Ndiaye',
    focus: 'Stockage et qualité',
    description:
        'Conservation, hygiène, gestion des stocks et contrôle de qualité.',
    order: 8,
  ),
  BatchDefinition(
    id: 'batch-qualite',
    name: 'Batch Qualité',
    mentor: 'Papa Faye',
    focus: 'Contrôle qualité',
    description: 'Évaluation des lots, normes et conformité des récoltes.',
    order: 9,
  ),
  BatchDefinition(
    id: 'batch-sante',
    name: 'Batch Santé',
    mentor: 'Moussa Tine',
    focus: 'Santé des cultures',
    description: 'Diagnostic de maladies, prévention et intervention rapide.',
    order: 10,
  ),
];

const List<TrainingDefinition> defaultTrainings = [
  TrainingDefinition(
    id: 'training-alchimie-01',
    batchId: 'batch-alchimie',
    title: 'Alchimie de base',
    description:
        'Découverte des mélanges, compatibilité des produits et préparation du matériel.',
    durationHours: 4,
    level: 'Débutant',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-traitement-01',
    batchId: 'batch-traitement',
    title: 'Traitement phytosanitaire',
    description: 'Protocoles d’application et sécurité sur le terrain.',
    durationHours: 5,
    level: 'Intermédiaire',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-semis-01',
    batchId: 'batch-semis',
    title: 'Semis et préparation du sol',
    description:
        'Planification, densité et conditions optimales pour les cultures.',
    durationHours: 4,
    level: 'Débutant',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-recolte-01',
    batchId: 'batch-recolte',
    title: 'Récolte et tri',
    description:
        'Bonnes pratiques de récolte, tri, stockage temporaire et évacuation.',
    durationHours: 5,
    level: 'Intermédiaire',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-entretien-01',
    batchId: 'batch-entretien',
    title: 'Entretien des parcelles',
    description: 'Suivi agronomique, désherbage et maintenance des cultures.',
    durationHours: 4,
    level: 'Débutant',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-irrigation-01',
    batchId: 'batch-irrigation',
    title: 'Irrigation et eau',
    description:
        'Estimation du besoin en eau, gestion des appareils et calendrier.',
    durationHours: 4,
    level: 'Intermédiaire',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-pulverisation-01',
    batchId: 'batch-pulverisation',
    title: 'Pulvérisation ciblée',
    description:
        'Calibration d’équipements et réduction des pertes et des risques.',
    durationHours: 5,
    level: 'Intermédiaire',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-stockage-01',
    batchId: 'batch-stockage',
    title: 'Stockage durable',
    description: 'Conservation, hygiène, quantification et gestion des stocks.',
    durationHours: 3,
    level: 'Débutant',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-qualite-01',
    batchId: 'batch-qualite',
    title: 'Contrôle qualité des récoltes',
    description: 'Normes de qualité, inspection de lots et documentation.',
    durationHours: 4,
    level: 'Intermédiaire',
    order: 1,
  ),
  TrainingDefinition(
    id: 'training-sante-01',
    batchId: 'batch-sante',
    title: 'Santé des cultures',
    description:
        'Diagnostic, prévention et interventions sur maladies et ravageurs.',
    durationHours: 5,
    level: 'Avancé',
    order: 1,
  ),
];
