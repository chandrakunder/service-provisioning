-- Disallow other users from accessing the template database

REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Create the tables needed for the Identity Service --

CREATE TABLE "Group"
(
  id uuid NOT NULL,
  name character varying NOT NULL,
  description character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone,
  CONSTRAINT pk_group PRIMARY KEY (id),
  CONSTRAINT uq_group_name UNIQUE (name)
);
ALTER TABLE "Group" OWNER TO tenant;

COMMENT ON COLUMN "Group"."id" IS '{{ManyWhoName:ID}}';
COMMENT ON COLUMN "Group"."name" IS '{{ManyWhoName:Name}}';
COMMENT ON COLUMN "Group"."description" IS '{{ManyWhoName:Description}}';
COMMENT ON COLUMN "Group"."created_at" IS '{{ManyWhoName:Created At}}';
COMMENT ON COLUMN "Group"."updated_at" IS '{{ManyWhoName:Updated At}}';

CREATE TABLE "User"
(
  id uuid NOT NULL,
  first_name character varying NOT NULL,
  last_name character varying NOT NULL,
  email character varying NOT NULL,
  password character varying(65),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL,
  CONSTRAINT pk_user PRIMARY KEY (id),
  CONSTRAINT uq_user_email UNIQUE (email)
);
ALTER TABLE "User" OWNER TO tenant;

COMMENT ON COLUMN "User"."id" IS '{{ManyWhoName:ID}}';
COMMENT ON COLUMN "User"."first_name" IS '{{ManyWhoName:First Name}}';
COMMENT ON COLUMN "User"."last_name" IS '{{ManyWhoName:Last Name}}';
COMMENT ON COLUMN "User"."email" IS '{{ManyWhoName:Email}}';
COMMENT ON COLUMN "User"."password" IS '{{ManyWhoName:Password}}';
COMMENT ON COLUMN "User"."created_at" IS '{{ManyWhoName:Created At}}';
COMMENT ON COLUMN "User"."updated_at" IS '{{ManyWhoName:Updated At}}';

CREATE TABLE "Membership"
(
  user_id uuid NOT NULL,
  group_id uuid NOT NULL,
  CONSTRAINT pk_membership PRIMARY KEY (user_id, group_id),
  CONSTRAINT fk_membership_group_id FOREIGN KEY (group_id)
  REFERENCES public."Group" (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT fk_membership_user_id FOREIGN KEY (user_id)
  REFERENCES public."User" (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE CASCADE
);
ALTER TABLE "Membership" OWNER TO tenant;

COMMENT ON COLUMN "Membership"."user_id" IS '{{ManyWhoName:User ID}}';
COMMENT ON COLUMN "Membership"."group_id" IS '{{ManyWhoName:Group ID}}';

-- Create the default tables to be pre-installed in each tenant --

CREATE TABLE public."Account"
(
  id SERIAL,
  "Name" character varying,
  "Address" character varying,
  CONSTRAINT "Account_pkey" PRIMARY KEY (id)
);

COMMENT ON COLUMN public."Account"."id" IS '{{ManyWhoName:ID}}';

CREATE TABLE public."Contact"
(
  id SERIAL,
  "FirstName" character varying, -- First name of the contact
  "LastName" character varying, -- Required. Last name of the contact.
  "AccountId" integer,
  "Mobile" character varying,
  "Email" character varying,
  CONSTRAINT "Contact_pkey" PRIMARY KEY (id),
  CONSTRAINT "Contact_AccountId_fkey" FOREIGN KEY ("AccountId")
      REFERENCES public."Account" (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

COMMENT ON COLUMN public."Contact"."id" IS '{{ManyWhoName:ID}}';
COMMENT ON COLUMN public."Contact"."FirstName" IS '{{ManyWhoName:First Name}}';
COMMENT ON COLUMN public."Contact"."LastName" IS '{{ManyWhoName:Last Name}}';
COMMENT ON COLUMN public."Contact"."AccountId" IS '{{ManyWhoName:Account ID}}';

CREATE TABLE public."Case"
(
  id SERIAL,
  "AccountId" integer,
  "ContactId" integer,
  "ClosedDate" timestamp with time zone,
  "ContactEmail" character varying,
  "Description" character varying,
  "Subject" character varying,
  "Status" character varying,
  CONSTRAINT "Case_pkey" PRIMARY KEY (id),
  CONSTRAINT "Case_AccountId_fkey" FOREIGN KEY ("AccountId")
      REFERENCES public."Account" (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "Case_ContactId_fkey" FOREIGN KEY ("ContactId")
      REFERENCES public."Contact" (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

COMMENT ON COLUMN public."Case"."id" IS '{{ManyWhoName:ID}}';
COMMENT ON COLUMN public."Case"."AccountId" IS '{{ManyWhoName:Account ID}}';
COMMENT ON COLUMN public."Case"."ContactId" IS '{{ManyWhoName:Contact ID}}';
COMMENT ON COLUMN public."Case"."ClosedDate" IS '{{ManyWhoName:Closed Date}}';
COMMENT ON COLUMN public."Case"."ContactEmail" IS '{{ManyWhoName:Contact Email}}';

CREATE TABLE public."Opportunity"
(
  id SERIAL,
  "AccountId" integer,
  "Amount" numeric, -- Estimated total sale amount.
  "CloseDate" timestamp with time zone, -- Date when the opportunity is expected to close.
  "Description" character varying,
  "Stage" character varying,
  CONSTRAINT "Opportunity_pkey" PRIMARY KEY (id),
  CONSTRAINT "Opportunity_AccountId_fkey" FOREIGN KEY ("AccountId")
      REFERENCES public."Account" (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

COMMENT ON COLUMN public."Opportunity"."id" IS '{{ManyWhoName:ID}}';
COMMENT ON COLUMN public."Opportunity"."AccountId" IS '{{ManyWhoName:Account ID}}';
COMMENT ON COLUMN public."Opportunity"."CloseDate" IS '{{ManyWhoName:Close Date}}';

CREATE TABLE public."Task"
(
  id SERIAL,
  "ContactId" integer,
  "Subject" character varying, -- Task Subject.
  "Description" character varying, -- Description of the Task.
  "Status" character varying, -- Status of the Task.
  "CloseDate" timestamp with time zone, -- Date when the Task is expected to close.
  CONSTRAINT "Task_pkey" PRIMARY KEY (id),
  CONSTRAINT "Task_ContactId_fkey" FOREIGN KEY ("ContactId")
      REFERENCES public."Contact" (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

COMMENT ON COLUMN public."Task"."id" IS '{{ManyWhoName:ID}}';
COMMENT ON COLUMN public."Task"."ContactId" IS '{{ManyWhoName:Contact ID}}';
COMMENT ON COLUMN public."Task"."CloseDate" IS '{{ManyWhoName:Close Date}}';