(ns floating-aces.example)

(def deck
  {#uuid "2006018d-800e-490f-8c17-a8f647e56189"
   {:floating-aces.core/name "first"}
   #uuid "ccb29058-eff2-46ec-bd3c-885fcb76e9fe"
   {:floating-aces.core/name "second"
    :floating-aces.core/description "the second one"}
   #uuid "719d9c4f-18f8-48de-ab9e-2b5cf715fcf1"
   {:floating-aces.core/name "third"
    :floating-aces.core/tags [:urgent]}
   #uuid "c626b3ce-2961-4123-8f72-7ef6f690a099"
   {:floating-aces.core/name "antonio"}
   #uuid "7441571a-1dea-40f9-972d-bae80e71327d"
   {:floating-aces.core/name "mary"}
   #uuid "be810609-4b5e-4ea9-851a-e90373b71b89"
   {:floating-aces.core/name "gabriel"}
   #uuid "1f5f5603-9e1e-430b-9a9f-260494fbb3cf"
   {:floating-aces.core/name "shaniqua"}
   #uuid "506576f7-041d-43a1-87d8-4c62cb0a2dd2"
   {:floating-aces.core/name "fiona"}
   #uuid "e42f7b2c-c790-4535-a579-e5a0c95f1eb2"
   {:floating-aces.core/name "bob"}})

(def example-shuffle
  [#uuid "2006018d-800e-490f-8c17-a8f647e56189"
   #uuid "ccb29058-eff2-46ec-bd3c-885fcb76e9fe"
   #uuid "719d9c4f-18f8-48de-ab9e-2b5cf715fcf1"
   #uuid "c626b3ce-2961-4123-8f72-7ef6f690a099"
   #uuid "7441571a-1dea-40f9-972d-bae80e71327d"
   #uuid "be810609-4b5e-4ea9-851a-e90373b71b89"
   #uuid "1f5f5603-9e1e-430b-9a9f-260494fbb3cf"
   #uuid "506576f7-041d-43a1-87d8-4c62cb0a2dd2"
   #uuid "e42f7b2c-c790-4535-a579-e5a0c95f1eb2"])

(def game
  {:floating-aces.core/deck deck
   :floating-aces.core/shuffles {"example" example-shuffle}})

