import 'package:esme26/domain/models/models.dart';

/// Deterministic fictional fixtures shared by every in-memory repository.
class MockData {
  MockData._();

  static final createdAt = DateTime.utc(2026, 10, 1, 8);
  static final location = GeoPoint(latitude: 48.8566, longitude: 2.3522);
  static final adress = Adress(street: '1 rue de la Demonstration', city: 'Paris', postalCode: '75001', country: 'France', location: location);
  static final customer = User(
    id: 'customer-1',
    firstName: 'JP',
    lastName: 'J',
    email: 'customer@example.test',
    birthDateInMillisFromEpoch: DateTime.utc(2000, 1, 1).millisecondsSinceEpoch,
    adress: adress,
    createdAt: createdAt,
  );
  static final artisan = User(
    id: 'artisan-1',
    firstName: 'Camille',
    lastName: 'Artisan',
    email: 'artisan@example.test',
    birthDateInMillisFromEpoch: DateTime.utc(1990, 1, 1).millisecondsSinceEpoch,
    adress: adress,
    roles: {UserRole.artisan},
    createdAt: createdAt,
  );
  static final versaillesAdress = Adress(
    street: '14 rue des Tilleuls',
    city: 'Versailles',
    postalCode: '78000',
    country: 'France',
    location: GeoPoint(latitude: 48.8049, longitude: 2.1204),
  );
  static final montreuilAdress = Adress(
    street: '5 rue des Vergers',
    city: 'Montreuil',
    postalCode: '93100',
    country: 'France',
    location: GeoPoint(latitude: 48.8638, longitude: 2.4485),
  );
  static final boulogneAdress = Adress(
    street: '22 avenue des Platanes',
    city: 'Boulogne-Billancourt',
    postalCode: '92100',
    country: 'France',
    location: GeoPoint(latitude: 48.8397, longitude: 2.2399),
  );
  static final sophie = User(
    id: 'customer-2',
    firstName: 'Sophie',
    lastName: 'Bernard',
    email: 'sophie@example.test',
    birthDateInMillisFromEpoch: DateTime.utc(
      1985,
      4,
      12,
    ).millisecondsSinceEpoch,
    adress: versaillesAdress,
    createdAt: DateTime.utc(2026, 11, 2, 9),
  );
  static final karim = User(
    id: 'customer-3',
    firstName: 'Karim',
    lastName: 'Haddad',
    email: 'karim@example.test',
    birthDateInMillisFromEpoch: DateTime.utc(1992, 9, 3).millisecondsSinceEpoch,
    adress: montreuilAdress,
    createdAt: DateTime.utc(2026, 11, 5, 18),
  );
  static final lea = User(
    id: 'customer-4',
    firstName: 'Léa',
    lastName: 'Martin',
    email: 'lea@example.test',
    birthDateInMillisFromEpoch: DateTime.utc(
      1978,
      1,
      30,
    ).millisecondsSinceEpoch,
    adress: boulogneAdress,
    createdAt: DateTime.utc(2026, 11, 10, 12),
  );
  static final List<User> users = List.unmodifiable([customer, artisan, sophie, karim, lea]);

  static final List<CustomerProfile> customerProfiles = List.unmodifiable([
    const CustomerProfile(userId: 'customer-1', presentation: 'Particulier souhaitant renover son logement.'),
    const CustomerProfile(userId: 'customer-2', presentation: 'Propriétaire d’une maison avec jardin à Versailles.'),
    const CustomerProfile(userId: 'customer-3', presentation: 'Jeune parent qui aménage son appartement.'),
    const CustomerProfile(userId: 'customer-4', presentation: 'Rénovation progressive d’un appartement ancien.'),
  ]);
  static final List<Trade> trades = List.unmodifiable([
    const Trade(id: 'trade-painting', name: 'Peinture'),
    const Trade(id: 'trade-interior-painting', name: 'Peinture intérieure', parentTradeId: 'trade-painting'),
    const Trade(id: 'trade-plumbing', name: 'Plomberie'),
    const Trade(id: 'trade-electricity', name: 'Électricité'),
    const Trade(id: 'trade-carpentry', name: 'Menuiserie'),
    const Trade(id: 'trade-tiling', name: 'Carrelage'),
    const Trade(id: 'trade-masonry', name: 'Maçonnerie'),
  ]);
  static final List<ArtisanProfile> artisanProfiles = List.unmodifiable([
    ArtisanProfile(
      userId: 'artisan-1',
      companyName: 'Atelier Demo',
      registrationNumber: 'MOCK-FR-001',
      registrationCountryCode: 'FR',
      description: 'Entreprise fictive de peinture et de renovation interieure.',
      businessAdress: adress,
      tradeIds: {'trade-interior-painting'},
      serviceAreas: [ServiceArea(center: location, radiusInKm: 25)],
      yearsOfExperience: 8,
      hourlyRate: Money(minorUnits: 4500),
      websiteUrl: Uri.parse('https://artisan.example.test'),
      verificationStatus: VerificationStatus.verified,
    ),
  ]);

  static final requestPhoto = Attachment(
    id: 'attachment-request',
    uploadedByUserId: 'customer-1',
    fileName: 'salon-avant.jpg',
    mimeType: 'image/jpeg',
    url: Uri.parse('https://media.example.test/salon-avant.jpg'),
    kind: AttachmentKind.image,
    sizeInBytes: 120000,
    createdAt: createdAt,
  );
  static final portfolioPhoto = Attachment(
    id: 'attachment-portfolio',
    uploadedByUserId: 'artisan-1',
    fileName: 'salon-apres.jpg',
    mimeType: 'image/jpeg',
    url: Uri.parse('https://media.example.test/salon-apres.jpg'),
    kind: AttachmentKind.image,
    sizeInBytes: 140000,
    createdAt: DateTime.utc(2026, 10, 5, 16),
  );
  static final insuranceFile = Attachment(
    id: 'attachment-insurance',
    uploadedByUserId: 'artisan-1',
    fileName: 'assurance-demo.pdf',
    mimeType: 'application/pdf',
    url: Uri.parse('https://media.example.test/assurance-demo.pdf'),
    kind: AttachmentKind.document,
    sizeInBytes: 50000,
    createdAt: createdAt,
  );
  static final invoiceFile = Attachment(
    id: 'attachment-invoice',
    uploadedByUserId: 'artisan-1',
    fileName: 'facture-demo.pdf',
    mimeType: 'application/pdf',
    url: Uri.parse('https://media.example.test/facture-demo.pdf'),
    kind: AttachmentKind.document,
    sizeInBytes: 40000,
    createdAt: DateTime.utc(2026, 10, 5, 17),
  );
  static final bathroomPhoto = Attachment(
    id: 'attachment-bathroom',
    uploadedByUserId: 'customer-2',
    fileName: 'salle-de-bain-actuelle.jpg',
    mimeType: 'image/jpeg',
    url: Uri.parse('https://media.example.test/salle-de-bain-actuelle.jpg'),
    kind: AttachmentKind.image,
    sizeInBytes: 210000,
    createdAt: DateTime.utc(2026, 11, 22, 18),
  );
  static final List<Attachment> attachments = List.unmodifiable([requestPhoto, portfolioPhoto, insuranceFile, invoiceFile, bathroomPhoto]);
  static final List<ProfessionalDocument> professionalDocuments = List.unmodifiable([
    ProfessionalDocument(
      id: 'document-insurance',
      artisanId: 'artisan-1',
      kind: ProfessionalDocumentKind.liabilityInsurance,
      title: 'Responsabilite civile professionnelle - demonstration',
      issuer: 'Assureur Demo',
      attachment: insuranceFile,
      issuedAt: createdAt,
      expiresAt: DateTime.utc(2027, 10, 1),
      verificationStatus: VerificationStatus.verified,
    ),
  ]);
  static final List<PortfolioProject> portfolioProjects = List.unmodifiable([
    PortfolioProject(
      id: 'portfolio-1',
      artisanId: 'artisan-1',
      title: 'Renovation du salon',
      description: 'Preparation des murs et peinture blanche.',
      tradeIds: {'trade-interior-painting'},
      media: [portfolioPhoto],
      completedAt: DateTime.utc(2026, 10, 5, 16),
      city: 'Paris',
    ),
  ]);

  static final firstPeriod = TimeSlot(startsAt: DateTime.utc(2026, 10, 5, 8), endsAt: DateTime.utc(2026, 10, 5, 16));
  static final secondPeriod = TimeSlot(startsAt: DateTime.utc(2026, 10, 8, 8), endsAt: DateTime.utc(2026, 10, 8, 16));
  static final List<WorkRequest> workRequests = List.unmodifiable([
    WorkRequest(
      id: 'request-1',
      customerId: 'customer-1',
      title: 'Repeindre le salon',
      description: 'Peinture blanche sur 20 mètres carrés de murs, plafond compris.',
      tradeIds: {'trade-interior-painting'},
      adress: adress,
      propertyType: PropertyType.apartment,
      status: WorkRequestStatus.closed,
      budget: Budget(minimum: Money(minorUnits: 100000), maximum: Money(minorUnits: 180000)),
      preferredPeriod: firstPeriod,
      attachments: [requestPhoto],
      createdAt: createdAt,
      updatedAt: firstPeriod.endsAt,
    ),
    WorkRequest(
      id: 'request-2',
      customerId: 'customer-1',
      title: 'Repeindre la cuisine',
      description: 'Préparation et peinture des murs de la cuisine, teinte vert d’eau.',
      tradeIds: {'trade-interior-painting'},
      adress: adress,
      propertyType: PropertyType.apartment,
      urgency: WorkUrgency.scheduled,
      status: WorkRequestStatus.assigned,
      budget: Budget(minimum: Money(minorUnits: 50000), maximum: Money(minorUnits: 80000)),
      preferredPeriod: secondPeriod,
      createdAt: createdAt,
      updatedAt: DateTime.utc(2026, 10, 2),
    ),
    // Published requests open to artisans (Ile-de-France), newest last.
    WorkRequest(
      id: 'request-3',
      customerId: 'customer-2',
      title: 'Muret de clôture dans le jardin',
      description: 'Construction d’un muret en parpaings enduits de 12 m de long et 80 cm de haut, en limite de propriété. Accès facile par le portail.',
      tradeIds: {'trade-masonry'},
      adress: versaillesAdress,
      propertyType: PropertyType.house,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 300000),
        maximum: Money(minorUnits: 500000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2027, 3, 1, 8),
        endsAt: DateTime.utc(2027, 3, 31, 17),
      ),
      createdAt: DateTime.utc(2026, 11, 16, 11, 30),
      updatedAt: DateTime.utc(2026, 11, 16, 11, 30),
    ),
    WorkRequest(
      id: 'request-4',
      customerId: 'customer-1',
      title: 'Rafraîchir les peintures du couloir',
      description: 'Couloir de 8 m de long avec des traces et des éclats sur les murs. Lessivage, reprise des enduits puis peinture satinée claire.',
      tradeIds: {'trade-painting'},
      adress: adress,
      propertyType: PropertyType.apartment,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 50000),
        maximum: Money(minorUnits: 90000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2026, 12, 1, 8),
        endsAt: DateTime.utc(2026, 12, 19, 17),
      ),
      createdAt: DateTime.utc(2026, 11, 18, 16),
      updatedAt: DateTime.utc(2026, 11, 18, 16),
    ),
    WorkRequest(
      id: 'request-5',
      customerId: 'customer-3',
      title: 'Bibliothèque sur mesure dans le salon',
      description: 'Création d’une bibliothèque en chêne massif sur un mur de 3,5 m, avec niches ouvertes en haut et placards fermés en bas.',
      tradeIds: {'trade-carpentry'},
      adress: montreuilAdress,
      propertyType: PropertyType.apartment,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 200000),
        maximum: Money(minorUnits: 350000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2027, 2, 1, 8),
        endsAt: DateTime.utc(2027, 2, 26, 17),
      ),
      createdAt: DateTime.utc(2026, 11, 19, 9, 20),
      updatedAt: DateTime.utc(2026, 11, 19, 9, 20),
    ),
    WorkRequest(
      id: 'request-6',
      customerId: 'customer-4',
      title: 'Mise aux normes du tableau électrique',
      description: 'Tableau d’origine des années 80 avec fusibles, à remplacer par un tableau à disjoncteurs. Appartement de 65 m² au 3e étage sans ascenseur.',
      tradeIds: {'trade-electricity'},
      adress: boulogneAdress,
      propertyType: PropertyType.apartment,
      urgency: WorkUrgency.scheduled,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 150000),
        maximum: Money(minorUnits: 250000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2026, 12, 7, 8),
        endsAt: DateTime.utc(2026, 12, 11, 17),
      ),
      createdAt: DateTime.utc(2026, 11, 20, 14, 45),
      updatedAt: DateTime.utc(2026, 11, 20, 14, 45),
    ),
    WorkRequest(
      id: 'request-7',
      customerId: 'customer-3',
      title: 'Peinture d’une chambre d’enfant',
      description: 'Chambre de 12 m² : rebouchage de quelques fissures, sous-couche et deux couches de peinture mate. Plafond blanc, murs vert sauge.',
      tradeIds: {'trade-interior-painting'},
      adress: montreuilAdress,
      propertyType: PropertyType.apartment,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 80000),
        maximum: Money(minorUnits: 120000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2026, 12, 14, 8),
        endsAt: DateTime.utc(2026, 12, 23, 17),
      ),
      createdAt: DateTime.utc(2026, 11, 21, 10),
      updatedAt: DateTime.utc(2026, 11, 21, 10),
    ),
    WorkRequest(
      id: 'request-8',
      customerId: 'customer-2',
      title: 'Rénovation complète de la salle de bain',
      description: 'Remplacement de la baignoire par une douche à l’italienne, faïence murale et nouveau carrelage au sol. Salle de bain de 6 m² à l’étage.',
      tradeIds: {'trade-plumbing', 'trade-tiling'},
      adress: versaillesAdress,
      propertyType: PropertyType.house,
      urgency: WorkUrgency.scheduled,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 700000),
        maximum: Money(minorUnits: 1000000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2027, 1, 11, 8),
        endsAt: DateTime.utc(2027, 1, 29, 17),
      ),
      attachments: [bathroomPhoto],
      createdAt: DateTime.utc(2026, 11, 22, 18, 10),
      updatedAt: DateTime.utc(2026, 11, 22, 18, 10),
    ),
    WorkRequest(
      id: 'request-9',
      customerId: 'customer-1',
      title: 'Fuite sous l’évier de la cuisine',
      description: 'De l’eau goutte sous l’évier depuis deux jours, probablement au niveau du siphon. Il faudrait remplacer le joint ou le siphon.',
      tradeIds: {'trade-plumbing'},
      adress: adress,
      propertyType: PropertyType.apartment,
      urgency: WorkUrgency.urgent,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 10000),
        maximum: Money(minorUnits: 25000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2026, 11, 25, 8),
        endsAt: DateTime.utc(2026, 11, 27, 18),
      ),
      createdAt: DateTime.utc(2026, 11, 23, 8, 30),
      updatedAt: DateTime.utc(2026, 11, 23, 8, 30),
    ),
    WorkRequest(
      id: 'request-10',
      customerId: 'customer-4',
      title: 'Remplacement d’un chauffe-eau en panne',
      description: 'Chauffe-eau électrique de 200 L en panne, à remplacer à l’identique dans le placard de la buanderie. Plus d’eau chaude depuis hier.',
      tradeIds: {'trade-plumbing'},
      adress: boulogneAdress,
      propertyType: PropertyType.apartment,
      urgency: WorkUrgency.urgent,
      status: WorkRequestStatus.published,
      budget: Budget(
        minimum: Money(minorUnits: 120000),
        maximum: Money(minorUnits: 180000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2026, 11, 25, 8),
        endsAt: DateTime.utc(2026, 11, 28, 18),
      ),
      createdAt: DateTime.utc(2026, 11, 24, 7, 15),
      updatedAt: DateTime.utc(2026, 11, 24, 7, 15),
    ),
    // Cancelled by its customer: visible in their list, not to artisans.
    WorkRequest(
      id: 'request-11',
      customerId: 'customer-1',
      title: 'Pose de parquet dans la chambre',
      description: 'Pose d’un parquet flottant en chêne sur 14 m², projet reporté à l’année prochaine.',
      tradeIds: {'trade-carpentry'},
      adress: adress,
      propertyType: PropertyType.apartment,
      status: WorkRequestStatus.cancelled,
      budget: Budget(
        minimum: Money(minorUnits: 90000),
        maximum: Money(minorUnits: 140000),
      ),
      preferredPeriod: TimeSlot(
        startsAt: DateTime.utc(2026, 11, 2, 8),
        endsAt: DateTime.utc(2026, 11, 13, 17),
      ),
      createdAt: DateTime.utc(2026, 10, 20, 19),
      updatedAt: DateTime.utc(2026, 10, 28, 9),
    ),
  ]);
  static final List<Quote> quotes = List.unmodifiable([
    Quote(
      id: 'quote-1',
      reference: 'DEV-DEMO-001',
      workRequestId: 'request-1',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      lines: [
        QuoteLine(
          description: 'Preparation et peinture du salon',
          quantity: 20,
          unit: QuoteUnit.squareMeter,
          unitPrice: Money(minorUnits: 5000),
          vatRateBasisPoints: 2000,
        ),
      ],
      status: QuoteStatus.accepted,
      createdAt: createdAt,
      validUntil: DateTime.utc(2026, 10, 31),
      proposedPeriod: firstPeriod,
      terms: 'Reglement a la fin des travaux.',
    ),
    Quote(
      id: 'quote-2',
      reference: 'DEV-DEMO-002',
      workRequestId: 'request-2',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      lines: [
        QuoteLine(
          description: 'Preparation et peinture de la cuisine',
          quantity: 10,
          unit: QuoteUnit.squareMeter,
          unitPrice: Money(minorUnits: 5000),
          vatRateBasisPoints: 2000,
        ),
      ],
      status: QuoteStatus.accepted,
      createdAt: createdAt,
      validUntil: DateTime.utc(2026, 10, 31),
      proposedPeriod: secondPeriod,
    ),
  ]);
  static final List<Job> jobs = List.unmodifiable([
    Job(
      id: 'job-1',
      workRequestId: 'request-1',
      acceptedQuoteId: 'quote-1',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      adress: adress,
      agreedTotal: quotes[0].total,
      scheduledPeriod: firstPeriod,
      status: JobStatus.completed,
      createdAt: DateTime.utc(2026, 10, 2),
      completedAt: firstPeriod.endsAt,
    ),
    Job(
      id: 'job-2',
      workRequestId: 'request-2',
      acceptedQuoteId: 'quote-2',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      adress: adress,
      agreedTotal: quotes[1].total,
      scheduledPeriod: secondPeriod,
      status: JobStatus.disputed,
      createdAt: DateTime.utc(2026, 10, 2),
    ),
  ]);
  static final List<Appointment> appointments = List.unmodifiable([
    Appointment(
      id: 'appointment-1',
      workRequestId: 'request-1',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      jobId: 'job-1',
      adress: adress,
      timeSlot: TimeSlot(startsAt: DateTime.utc(2026, 10, 3, 10), endsAt: DateTime.utc(2026, 10, 3, 11)),
      status: AppointmentStatus.completed,
      notes: 'Visite technique avant travaux.',
    ),
  ]);
  static final List<Availability> availabilities = List.unmodifiable([
    Availability(id: 'availability-1', artisanId: 'artisan-1', timeSlot: firstPeriod, status: AvailabilityStatus.unavailable),
    Availability(
      id: 'availability-2',
      artisanId: 'artisan-1',
      timeSlot: TimeSlot(startsAt: DateTime.utc(2026, 10, 12, 8), endsAt: DateTime.utc(2026, 10, 12, 17)),
      status: AvailabilityStatus.available,
    ),
  ]);

  static final List<Conversation> conversations = List.unmodifiable([
    Conversation(
      id: 'conversation-1',
      customerId: 'customer-1',
      artisanId: 'artisan-1',
      workRequestId: 'request-1',
      lastMessageId: 'message-2',
      createdAt: createdAt,
      updatedAt: createdAt.add(const Duration(hours: 2)),
    ),
  ]);
  static final List<Message> messages = List.unmodifiable([
    Message(
      id: 'message-1',
      conversationId: 'conversation-1',
      senderId: 'customer-1',
      text: 'Bonjour, voici une photo du salon.',
      attachments: [requestPhoto],
      sentAt: createdAt,
      readAt: createdAt.add(const Duration(hours: 1)),
    ),
    Message(
      id: 'message-2',
      conversationId: 'conversation-1',
      senderId: 'artisan-1',
      text: 'Bonjour, je vous propose une visite avant les travaux.',
      sentAt: createdAt.add(const Duration(hours: 2)),
    ),
  ]);
  static final List<Review> reviews = List.unmodifiable([
    Review(
      id: 'review-1',
      jobId: 'job-1',
      customerId: 'customer-1',
      artisanId: 'artisan-1',
      rating: 5,
      comment: 'Travail soigne et chantier propre.',
      createdAt: DateTime.utc(2026, 10, 6, 9),
      artisanReply: 'Merci pour votre retour.',
      repliedAt: DateTime.utc(2026, 10, 6, 10),
    ),
  ]);
  static final List<Invoice> invoices = List.unmodifiable([
    Invoice(
      id: 'invoice-1',
      number: 'FAC-DEMO-001',
      jobId: 'job-1',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      lines: quotes[0].lines,
      status: InvoiceStatus.paid,
      issuedAt: DateTime.utc(2026, 10, 5, 17),
      dueAt: DateTime.utc(2026, 10, 20),
      paidAt: DateTime.utc(2026, 10, 6),
      documentId: invoiceFile.id,
    ),
    Invoice(
      id: 'invoice-2',
      number: 'FAC-DEMO-002',
      jobId: 'job-2',
      artisanId: 'artisan-1',
      customerId: 'customer-1',
      lines: quotes[1].lines,
      status: InvoiceStatus.paid,
      issuedAt: DateTime.utc(2026, 10, 8, 17),
      dueAt: DateTime.utc(2026, 10, 23),
      paidAt: DateTime.utc(2026, 10, 9),
    ),
  ]);
  static final List<Payment> payments = List.unmodifiable([
    Payment(
      id: 'payment-1',
      invoiceId: 'invoice-1',
      customerId: 'customer-1',
      artisanId: 'artisan-1',
      amount: invoices[0].total,
      purpose: PaymentPurpose.full,
      status: PaymentStatus.succeeded,
      providerReference: 'mock-payment-1',
      createdAt: DateTime.utc(2026, 10, 6),
      paidAt: DateTime.utc(2026, 10, 6),
    ),
    Payment(
      id: 'payment-2',
      invoiceId: 'invoice-2',
      customerId: 'customer-1',
      artisanId: 'artisan-1',
      amount: invoices[1].total,
      purpose: PaymentPurpose.full,
      status: PaymentStatus.succeeded,
      providerReference: 'mock-payment-2',
      createdAt: DateTime.utc(2026, 10, 9),
      paidAt: DateTime.utc(2026, 10, 9),
    ),
  ]);
  static final List<Refund> refunds = List.unmodifiable([
    Refund(
      id: 'refund-1',
      paymentId: 'payment-2',
      amount: Money(minorUnits: 10000),
      reason: 'Geste commercial propose pour les finitions de la cuisine.',
      createdAt: DateTime.utc(2026, 10, 10),
    ),
  ]);
  static final List<Dispute> disputes = List.unmodifiable([
    Dispute(
      id: 'dispute-1',
      jobId: 'job-2',
      openedByUserId: 'customer-1',
      reason: 'Finitions',
      description: 'Une reprise des finitions de la cuisine est demandee.',
      status: DisputeStatus.underReview,
      createdAt: DateTime.utc(2026, 10, 9, 12),
    ),
  ]);
  static final List<Favorite> favorites = List.unmodifiable([Favorite(customerId: 'customer-1', artisanId: 'artisan-1', createdAt: createdAt)]);
  static final List<AppNotification> appNotifications = List.unmodifiable([
    AppNotification(
      id: 'notification-1',
      userId: 'customer-1',
      kind: NotificationKind.message,
      relatedEntityId: 'message-2',
      title: 'Nouveau message',
      body: 'Votre artisan vous propose une visite.',
      createdAt: createdAt.add(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'notification-2',
      userId: 'artisan-1',
      kind: NotificationKind.review,
      relatedEntityId: 'review-1',
      title: 'Nouvel avis',
      body: 'Un particulier vous a laisse un avis.',
      createdAt: DateTime.utc(2026, 10, 6, 9),
      readAt: DateTime.utc(2026, 10, 6, 10),
    ),
  ]);
}
