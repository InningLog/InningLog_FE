import fs from "node:fs";
import path from "node:path";
import StyleDictionary from "style-dictionary";
import { register, expandTypesMap } from "@tokens-studio/sd-transforms";

register(StyleDictionary);

const TYPO_PROPS = new Set([
  "fontFamily",
  "fontWeight",
  "fontSize",
  "lineHeight",
  "letterSpacing",
]);

/** core 래퍼를 벗겨서 참조({fontWeights...})가 루트에서 동작하게 만듦 */
function normalizeTokens(inputPath, outputPath) {
  const raw = JSON.parse(fs.readFileSync(inputPath, "utf8"));
  const normalized = raw.core ?? raw[""] ?? raw;

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, JSON.stringify(normalized, null, 2), "utf8");
}

/** hex -> Color(0xFFRRGGBB) */
function hexToFlutterColor(hex) {
  if (typeof hex !== "string") return "const Color(0x00000000)";
  const h = hex.replace("#", "").trim();
  if (h.length === 6) return `Color(0xFF${h.toUpperCase()})`;
  if (h.length === 8) {
    const rrggbb = h.slice(0, 6);
    const aa = h.slice(6, 8);
    return `const Color(0x${aa.toUpperCase()}${rrggbb.toUpperCase()})`;
  }
  return "const Color(0x00000000)";
}

const dartString = (s) =>
  `'${String(s).replaceAll("\\", "\\\\").replaceAll("'", "\\'")}'`;

const normalizeProp = (k) =>
  String(k)
    .trim()
    .replace(/-([a-z])/g, (_, c) => c.toUpperCase());

const unwrapValue = (v) => {
  // StyleDictionary나 Tokens Studio 변환 과정에서 값이 { value: ... } / { $value: ... }로 감싸질 수 있음
  if (v && typeof v === "object") {
    if ("$value" in v) return v.$value;
    if ("value" in v) return v.value;
  }
  return v;
};

const toNum = (v) => {
  const x = unwrapValue(v);
  if (typeof x === "number") return x;
  const n = Number(x);
  return Number.isFinite(n) ? n : null;
};

const toFontWeight = (v) => {
  const x = unwrapValue(v);

  // 숫자로 들어오면 FontWeight.wXXX
  const n = typeof x === "number" ? x : Number(x);
  if (Number.isFinite(n) && n >= 100 && n <= 900) {
    const w = Math.round(n / 100) * 100;
    return `FontWeight.w${w}`;
  }

  // 문자열(Bold/SemiBold/Regular 등)
  const map = {
    Thin: "FontWeight.w100",
    ExtraLight: "FontWeight.w200",
    Light: "FontWeight.w300",
    Regular: "FontWeight.w400",
    Medium: "FontWeight.w500",
    SemiBold: "FontWeight.w600",
    Bold: "FontWeight.w700",
    ExtraBold: "FontWeight.w800",
    Black: "FontWeight.w900",
  };
  return map[String(x)] ?? null;
};

const toLetterSpacingPx = (letterSpacing, fontSize) => {
  const ls = unwrapValue(letterSpacing);
  if (ls == null) return null;

  if (typeof ls === "number") return ls;

  const s = String(ls).trim();

  // "-1%" 같은 값이면 fontSize 기준으로 px 환산
  if (s.endsWith("%") && typeof fontSize === "number") {
    const p = Number(s.slice(0, -1));
    if (!Number.isFinite(p)) return null;
    return Number(((fontSize * p) / 100).toFixed(4));
  }

  // "0.02em" 같은 값이면 fontSize 기준 환산
  if (s.endsWith("em") && typeof fontSize === "number") {
    const em = Number(s.slice(0, -2));
    if (!Number.isFinite(em)) return null;
    return Number((fontSize * em).toFixed(4));
  }

  const n = Number(s);
  return Number.isFinite(n) ? n : null;
};

const toHeightMultiplier = (lineHeight, fontSize) => {
  const lh = unwrapValue(lineHeight);
  if (lh == null) return null;
  if (String(lh).toUpperCase() === "AUTO") return null;

  if (
    typeof lh === "number" &&
    typeof fontSize === "number" &&
    fontSize !== 0
  ) {
    return Number((lh / fontSize).toFixed(4));
  }

  const n = Number(lh);
  if (Number.isFinite(n) && typeof fontSize === "number" && fontSize !== 0) {
    return Number((n / fontSize).toFixed(4));
  }

  return null;
};

const resolveRef = (v, dictionary) => {
  const x = unwrapAny(v);

  // {fontFamilies.pretendard} 같은 reference면 dictionary.tokens에서 찾아가기
  if (typeof x === "string") {
    const m = x.match(/^\{(.+)\}$/);
    if (m) {
      const refPath = m[1].split(".");
      let node = dictionary.tokens;

      for (const seg of refPath) {
        if (!node) break;
        node = node[seg];
      }

      // node가 토큰이면 node.value / node.$value에 실제 값이 있음
      const resolved = unwrapAny(node?.value ?? node?.$value ?? node);
      return resolved;
    }
  }

  return x;
};
// basePath로 Dart const 이름 만들기 (현재 네 결과처럼 bodyBody1Rg 형태 유지)
const styleNameFromBasePath = (basePath) => {
  const raw = basePath.join(" ");
  return raw
    .replaceAll(/[()]/g, " ")
    .replaceAll(/[^a-zA-Z0-9]+/g, " ")
    .trim()
    .split(/\s+/)
    .map((w, i) =>
      i === 0
        ? w[0].toLowerCase() + w.slice(1)
        : w[0].toUpperCase() + w.slice(1)
    )
    .join("");
};

/** token.path 기반으로 Dart identifier */
function makeColorName(token) {
  const p = (token.path || []).filter(Boolean);
  // ["primary", "primary-500"] => primary500
  if (p.length >= 2) {
    const group = p[0];
    const key = p[1];
    const prefix = `${group}-`;
    if (typeof key === "string" && key.startsWith(prefix)) {
      return `${group}${key.slice(prefix.length)}`.replace(
        /[^a-zA-Z0-9_]/g,
        ""
      );
    }
    return `${group}_${key}`.replace(/[^a-zA-Z0-9_]/g, "");
  }
  return (token.name || "color").replace(/[^a-zA-Z0-9_]/g, "");
}

/** colors 포맷 */
StyleDictionary.registerFormat({
  name: "flutter/colors-class",
  format: ({ dictionary, options }) => {
    const className = options?.className ?? "AppColors";

    // ✅ type이 'color'가 아닌 경우도 대비(혹시나 변환이 덜 된 경우)
    const tokens = dictionary.allTokens.filter(
      (t) => (t.type ?? t.original?.$type ?? t.$type) === "color"
    );

    const lines = [];
    lines.push("// GENERATED CODE - DO NOT MODIFY BY HAND");
    lines.push("import 'package:flutter/material.dart';");
    lines.push("");
    lines.push(`class ${className} {`);
    lines.push(`  const ${className}._();`);
    lines.push("");

    for (const t of tokens) {
      const name = makeColorName(t);
      const hex =
        typeof t.value === "string"
          ? t.value
          : (t.value?.$value ?? t.original?.$value);
      lines.push(`  static const Color ${name} = ${hexToFlutterColor(hex)};`);
    }

    lines.push("}");
    lines.push("");
    return lines.join("\n");
  },
});

/** typography 포맷 */
StyleDictionary.registerFormat({
  name: "flutter/textstyles-class",
  format: ({ dictionary }) => {
    // ---- helpers (너 파일에 이미 있으면 중복 제거 가능) ----
    const unwrapAny = (v) => {
      if (v && typeof v === "object") {
        if ("$value" in v) return v.$value;
        if ("value" in v) return v.value;
      }
      return v;
    };

    const getTokenRawValue = (t) => {
      let v = t?.$value ?? t?.value;
      if (v === undefined) v = t?.original?.$value ?? t?.original?.value;
      return unwrapAny(v);
    };

    const resolveRef = (v, dict) => {
      const x = unwrapAny(v);
      if (typeof x === "string") {
        const m = x.match(/^\{(.+)\}$/);
        if (m) {
          const refPath = m[1].split(".");
          let node = dict.tokens;
          for (const seg of refPath) node = node?.[seg];
          return unwrapAny(node?.$value ?? node?.value ?? node);
        }
      }
      return x;
    };

    // typography 속성만
    const TYPO_PROPS = new Set([
      "fontfamily",
      "fontweight",
      "fontsize",
      "lineheight",
      "letterspacing",
    ]);

    const normalizeProp = (s) => String(s).replace(/\s+/g, "").toLowerCase();

    // ✅ 너의 실제 토큰 path는 [category, styleName, item] 이라서 detectProp 단순화 가능
    const detectProp = (pathArr) => {
      if (!Array.isArray(pathArr) || pathArr.length < 3) return null;

      const prop = normalizeProp(pathArr[pathArr.length - 1]); // fontFamily
      if (!TYPO_PROPS.has(prop)) return null;

      const basePath = pathArr.slice(0, pathArr.length - 1); // ['body','Body 3(M)']
      if (basePath.length < 2) return null;

      return { prop, basePath };
    };

    const styleNameFromBasePath = (basePath) => {
      // ['body','Body 3(M)'] -> bodyBody3M
      const [cat, name] = basePath;
      const sanitize = (x) =>
        String(x)
          .replace(/[()]/g, "")
          .replace(/[^a-zA-Z0-9]+/g, " ")
          .trim()
          .split(/\s+/)
          .map((w, i) => (i === 0 ? w : w[0].toUpperCase() + w.slice(1)))
          .join("");

      const catPart = sanitize(cat);
      const namePart = sanitize(name);
      return catPart + namePart[0].toUpperCase() + namePart.slice(1);
    };

    const dartString = (s) => JSON.stringify(String(s));

    const toNum = (x) => {
      const v = unwrapAny(x);
      if (typeof v === "number") return v;
      if (typeof v === "string" && v.trim() !== "" && !isNaN(Number(v)))
        return Number(v);
      return null;
    };

    const toFontWeight = (w) => {
      const v = String(unwrapAny(w) ?? "").toLowerCase();
      const map = {
        thin: "FontWeight.w100",
        extralight: "FontWeight.w200",
        ultralight: "FontWeight.w200",
        light: "FontWeight.w300",
        regular: "FontWeight.w400",
        normal: "FontWeight.w400",
        medium: "FontWeight.w500",
        semibold: "FontWeight.w600",
        demibold: "FontWeight.w600",
        bold: "FontWeight.w700",
        extrabold: "FontWeight.w800",
        ultrabold: "FontWeight.w800",
        black: "FontWeight.w900",
        heavy: "FontWeight.w900",
      };
      return map[v] ?? null;
    };

    const toHeightMultiplier = (lineHeight, fontSize) => {
      if (!lineHeight || !fontSize) return null;
      // lineHeight가 AUTO면 null 처리(너 토큰에 "AUTO"도 있었지)
      if (typeof lineHeight === "string" && lineHeight.toUpperCase() === "AUTO")
        return null;
      const lh = toNum(lineHeight);
      const fs = toNum(fontSize);
      if (!lh || !fs) return null;
      const ratio = lh / fs;
      return Number(ratio.toFixed(3));
    };

    const toLetterSpacingPx = (ls, fontSize) => {
      const v = unwrapAny(ls);
      if (v == null) return null;
      const fs = toNum(fontSize);
      if (!fs) return null;

      if (typeof v === "number") return Number(v.toFixed(3));

      if (typeof v === "string") {
        const s = v.trim();
        // "-1%" 같은 퍼센트 케이스
        const pm = s.match(/^(-?\d+(\.\d+)?)%$/);
        if (pm) {
          const pct = Number(pm[1]) / 100;
          return Number((fs * pct).toFixed(3));
        }
        // px처럼 숫자 문자열
        if (!isNaN(Number(s))) return Number(Number(s).toFixed(3));
      }
      return null;
    };

    // ---- 1) 조각 토큰을 그룹핑해서 typography 합치기 ----
    const groups = new Map();

    for (const t of dictionary.allTokens) {
      const hit = detectProp(t.path);
      if (!hit) continue;

      const { prop, basePath } = hit;
      const key = basePath.join("|");

      const g = groups.get(key) ?? { basePath, parts: {} };

      const raw = getTokenRawValue(t); // ✅ $value 기반
      const resolved = resolveRef(raw, dictionary); // ref면 풀고, 아니면 그대로
      g.parts[prop] = resolved;

      groups.set(key, g);
    }

    const styles = Array.from(groups.values());

    // 디버그: head/body가 잡히는지 확인
    // console.log("textstyles total:", styles.length);
    // console.log(
    //   "sections:",
    //   styles.reduce((acc, s) => {
    //     acc[s.basePath[0]] = (acc[s.basePath[0]] || 0) + 1;
    //     return acc;
    //   }, {})
    // );

    // ---- 2) 출력 ----
    const out = [];
    out.push("// GENERATED CODE - DO NOT MODIFY BY HAND");
    out.push("import 'package:flutter/material.dart';");
    out.push("");
    out.push("class AppTextStyles {");
    out.push("  const AppTextStyles._();");
    out.push("");

    styles.sort((a, b) =>
      styleNameFromBasePath(a.basePath).localeCompare(
        styleNameFromBasePath(b.basePath)
      )
    );

    for (const s of styles) {
      const name = styleNameFromBasePath(s.basePath);

      const fontFamily = resolveRef(s.parts.fontfamily, dictionary);
      const fontSize = toNum(resolveRef(s.parts.fontsize, dictionary));
      const fontWeight = toFontWeight(
        resolveRef(s.parts.fontweight, dictionary)
      );

      const lineHeightRaw = resolveRef(s.parts.lineheight, dictionary);
      const height = toHeightMultiplier(lineHeightRaw, fontSize);

      const letterSpacingRaw = resolveRef(s.parts.letterspacing, dictionary);
      const letterSpacing = toLetterSpacingPx(letterSpacingRaw, fontSize);

      out.push(`  static const TextStyle ${name} = TextStyle(`);
      if (typeof fontFamily === "string")
        out.push(`    fontFamily: ${dartString(fontFamily)},`);
      if (fontSize != null) out.push(`    fontSize: ${fontSize},`);
      if (fontWeight != null) out.push(`    fontWeight: ${fontWeight},`);
      if (height != null) out.push(`    height: ${height},`);
      if (letterSpacing != null)
        out.push(`    letterSpacing: ${letterSpacing},`);
      out.push("  );");
      out.push("");
    }

    out.push("}");
    out.push("");
    return out.join("\n");
  },
});

// ---- build 실행 ----
const repoRoot = path.resolve(process.cwd(), "../.."); // tools/tokens 기준
const input = path.join(repoRoot, "tokens/token.json");
const tmpOut = path.join(repoRoot, ".tmp/tokens.normalized.json");

normalizeTokens(input, tmpOut);

const sd = new StyleDictionary({
  source: [tmpOut],
  preprocessors: ["tokens-studio"], // ✅ 중요: $type/$value/참조 해석
  expand: {
    typesMap: expandTypesMap, // ✅ typography 같은 복합 타입 확장에 도움
  },
  platforms: {
    flutter: {
      buildPath: path.join(repoRoot, "lib/shared/theme/"),
      transforms: ["attribute/cti", "name/camel"], // 이름/속성 기본 처리
      files: [
        {
          destination: "app_colors.dart",
          format: "flutter/colors-class",
          options: { className: "AppColors" },
        },
        {
          destination: "app_text_styles.dart",
          format: "flutter/textstyles-class",
          options: { className: "AppTextStyles" },
        },
      ],
    },
  },
});

// v4는 초기화/빌드가 async
await sd.hasInitialized;
await sd.cleanAllPlatforms();
await sd.buildAllPlatforms();

console.log("✅ Generated app_colors.g.dart / app_text_styles.g.dart");
