export type DomainKey =
  | "career"
  | "health"
  | "craft"
  | "relationships"
  | "home"
  | "wealth";

export interface DomainDefinition {
  key: DomainKey;
  name: string;
  accentColor: string;
}
