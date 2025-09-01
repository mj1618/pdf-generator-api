import { NextFunction, Request, Response, Router } from "express";
import puppeteer from "puppeteer";

export const index = Router();

const checkAuthorization = (
    req: Request,
    res: Response,
    next: NextFunction,
) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return res.status(401).send("Unauthorized");
    }
    const token = authHeader.split(" ")[1];
    if (token !== process.env.API_KEY) {
        return res.status(401).send("Unauthorized");
    }
    next();
};

index.get("/api/test", checkAuthorization, (req, res) => {
    res.send("Hello World");
});

// curl -H "Authorization: Bearer abc1234" http://localhost:3001/api/test

index.get("/api/pdf", checkAuthorization, async (req, res) => {
    try {
        const pdf = await generatePdf();
        res.contentType("application/pdf");
        res.setHeader(
            "Content-Disposition",
            "attachment; filename=invoice.pdf",
        );
        res.end(pdf);
    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error: " + error.message);
    }
});

const generatePdf = async () => {
    const browser = await puppeteer.launch();
    const [page] = await browser.pages();

    await page.goto("https://www.google.com", { waitUntil: "networkidle0" });
    const pdf = await page.pdf({ format: "A4" });

    browser.close();

    return pdf;
};
