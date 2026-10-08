/** Shared Flutter/Three.js protocol; maps to RendererCommand in Dart. */
export type Chapter = "explore" | "arch" | "sec";
export type Device =
  | "Camera"
  | "Gateway"
  | "GlassSensor"
  | "Controller"
  | "Cylinder"
  | "Embedded"
  | "Orb";
export type Command =
  | { type: "SET_CHAPTER"; data: { chapter: Chapter } }
  | { type: "SET_PROGRESS"; data: { progress: number } }
  | { type: "GOTO_STAGE"; data: { stage: number } }
  | {
      type: "SET_VIEWPORT";
      data: {
        class:
          | "desktopWide"
          | "desktop"
          | "laptopCompact"
          | "tabletLandscape"
          | "tabletPortrait"
          | "mobileLarge"
          | "mobileSmall";
      };
    }
  | { type: "SET_THEME"; data: { dark: boolean } }
  | {
      type:
        | "SET_INTERACTION_ENABLED"
        | "SET_RENDERING_ENABLED"
        | "SET_REDUCED_MOTION";
      data: { enabled: boolean };
    }
  | {
      type: "RESET_SCENE" | "CLEAR_SELECTION" | "DISPOSE";
      data: Record<string, never>;
    };
export type RendererEvent =
  | {
      type: "MODEL_READY";
      data: {
        packetCount: number;
        routeCount: number;
        clipCount: number;
        bounds: unknown;
        extrasCount: number;
      };
    }
  | { type: "MODEL_ERROR"; data: { message: string; stack?: string } }
  | {
      type: "DEVICE_HOVER" | "DEVICE_SELECTED";
      data: { device: Device | null; status?: "normal" | "anomalous" };
    }
  | { type: "SCROLL_INPUT"; data: { delta: number } }
  | {
      type: "RENDERER_STATUS";
      data: {
        chapter: Chapter;
        progress: number;
        activeStage: number;
        hero: boolean;
        renderingEnabled: boolean;
        parameters: Record<string, number | boolean>;
        annotations: Array<{ id: string; label: string; x: number; y: number }>;
        demonstration: true;
      };
    };
export type Envelope<T = Command | RendererEvent> = T & {
  protocol: "autopolicy.v1";
  session: string;
};
